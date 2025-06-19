/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ConfigurationConstant } from '@kit.AbilityKit';
import { curves } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import type { GlobalInfoModel } from '@ohos/common';
import {
  BaseVM,
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  Logger,
  PageContext,
  ProductSeriesEnum,
  StatusBarColorType,
  WindowUtil,
} from '@ohos/common';
import type { BannerData } from '../model/BannerData';
import { BANNER_SCALE_FACTOR, BannerTypeEnum, TITLE_SCALE_FACTOR } from '../model/BannerData';
import type { ArticleDetailParams, ComponentDetailParams, SampleDetailParams } from '../model/RouterParams';
import { TAB_CONTENT_STATUSES, TabBarType } from '../model/TabStatusBarModel';
import type { BaseHomeState } from './BaseHomeState';

const TAG = '[BaseHomeViewModel]';
const BANNER_HEIGHT_LG = 242;
const TITLE_MAX_SCALE = 1.1;
const TITLE_MIN_SCALE = 1;
const TITLE_OFFSET_FACTOR = 0.01;

@Observed
export class BaseHomeViewModel<T extends BaseHomeState> extends BaseVM<BaseHomeState> {
  protected state: T;
  protected readonly pageSize: number = 30;
  private originBannerHeight: number = 0;
  private springBackAnimation: curves.ICurve = curves.interpolatingSpring(0, 1, 288, 30);

  public constructor(initialState: T) {
    super(initialState);
    this.state = initialState;
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    const isLargeWidth: boolean = (globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL);
    this.state.topNavigationData.bgColor = isLargeWidth ? '#FFF1F3F5' : '#00FFFFFF';
    this.state.topNavigationData.titleColor = isLargeWidth ? StatusBarColorType.BLACK : StatusBarColorType.WHITE;
    const naviTitleHeight: number =
      globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT + CommonConstants.SPACE_8;
    this.state.bannerState.bannerHeight = new BreakpointType({
      sm: deviceInfo.productSeries === ProductSeriesEnum.VDE ?
        CommonConstants.BANNER_ASPECT_VERDE * globalInfoModel.deviceWidth :
        CommonConstants.BANNER_ASPECT_SM * globalInfoModel.deviceWidth,
      md: CommonConstants.BANNER_ASPECT_MD * globalInfoModel.deviceWidth,
      lg: BANNER_HEIGHT_LG + naviTitleHeight,
      xl: BANNER_HEIGHT_LG + naviTitleHeight,
    }).getValue(globalInfoModel.currentBreakpoint);
    this.state.bannerHeight = this.state.bannerState.bannerHeight;
    this.originBannerHeight = this.state.bannerHeight;
  }

  public getState(): T {
    return this.state;
  }

  public sendEvent<P>(eventParam: BaseHomeEventParam<P>): boolean | void {
    const eventType: BaseHomeEventType = eventParam.type;
    if (eventType === BaseHomeEventType.JUMP_BANNER_DETAIL) {
      return this.jumpBannerDetail(eventParam.param as BannerData);
    } else if (eventType === BaseHomeEventType.HANDLE_SCROLL_OFFSET) {
      return this.handleListOffset(eventParam.param as OffsetParam);
    } else if (eventType === BaseHomeEventType.CALCULATE_BANNER_HEIGHT) {
      return this.calculateBannerHeight(eventParam.param as CalculateHeightParam);
    } else if (eventType === BaseHomeEventType.CHANGE_BANNER_HEIGHT) {
      return this.changeBannerHeight();
    } else if (eventType === BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE) {
      return this.handleBreakpointChange(eventParam.param as OffsetParam);
    } else if (eventType === BaseHomeEventType.HANDLE_COLOR_CHANGE) {
      return this.handleColorModeChange(eventParam.param as OffsetParam);
    }
    return false;
  }

  protected calculateBannerHeight(param: CalculateHeightParam): boolean {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    if (param.yOffset === 0) {
      this.state.hasEdgeEffect = false;
    } else {
      this.state.hasEdgeEffect = param.offset > 0;
    }
    if (globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL || param.yOffset > 0) {
      return false;
    }
    if (param.state === ScrollState.Scroll && param.offset !== 0) {
      this.state.currentScrollState = ScrollState.Scroll;
      const currentBannerHeight: number = this.state.bannerHeight - param.offset;
      if (currentBannerHeight < this.originBannerHeight) {
        this.state.currentScrollState = ScrollState.Fling;
        this.state.bannerState.bannerHeight = this.originBannerHeight;
        this.state.bannerHeight = this.state.bannerState.bannerHeight;
        return false;
      }
      const bannerOffset: number = -(param.offset / BANNER_SCALE_FACTOR);
      this.state.bannerState.bannerHeight += bannerOffset;
      this.state.bannerHeight = this.state.bannerState.bannerHeight;
      const titleOffset: number = bannerOffset / TITLE_SCALE_FACTOR;
      const titleOffsetY: number = this.state.topNavigationData.titleOffsetY + titleOffset;

      this.state.topNavigationData.titleOffsetY = titleOffsetY > 0 ? titleOffsetY : 0;
      let titleScale = this.state.topNavigationData.titleScale + TITLE_OFFSET_FACTOR * titleOffset;
      if (titleScale > TITLE_MAX_SCALE) {
        titleScale = TITLE_MAX_SCALE;
      } else if (titleScale < TITLE_MIN_SCALE) {
        titleScale = TITLE_MIN_SCALE;
      }
      this.state.topNavigationData.titleScale = titleScale;
      return true;
    } else if (this.state.currentScrollState === ScrollState.Scroll && param.state === ScrollState.Fling) {
      this.bannerSpringBack();
      return true;
    }
    return false;
  }

  protected handleBreakpointChange(offsetParam: OffsetParam) {
    this.changeBannerHeight();
    offsetParam.breakpointChange = true;
    this.handleListOffset(offsetParam);
  }

  protected handleColorModeChange(offsetParam: OffsetParam) {
    const pageContext: PageContext = AppStorage.get('pageContext') as PageContext;
    if (pageContext.navPathStack.size() > 1) {
      return;
    }
    const isDark: boolean = AppStorage.get('systemColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (isDark) {
      this.state.topNavigationData.titleColor = `rgba(255,255,255, 1)`;
    } else {
      offsetParam.breakpointChange = true;
      this.handleListOffset(offsetParam);
    }
  }

  protected changeBannerHeight(): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    const naviTitleHeight: number =
      globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT + CommonConstants.SPACE_8;
    this.state.bannerState.bannerHeight = new BreakpointType({
      sm: (deviceInfo.productSeries === ProductSeriesEnum.VDE) ?
        CommonConstants.BANNER_ASPECT_VERDE * globalInfoModel.deviceWidth :
        CommonConstants.BANNER_ASPECT_SM * globalInfoModel.deviceWidth,
      md: CommonConstants.BANNER_ASPECT_MD * globalInfoModel.deviceWidth,
      lg: BANNER_HEIGHT_LG + naviTitleHeight,
      xl: CommonConstants.BANNER_ASPECT_XL *
      Math.floor((globalInfoModel.deviceWidth - CommonConstants.SIDE_BAR_WIDTH) / 2.7) + naviTitleHeight,
    }).getValue(globalInfoModel.currentBreakpoint);
    this.state.bannerHeight = this.state.bannerState.bannerHeight;
    this.originBannerHeight = this.state.bannerHeight;
  }

  protected handleListOffset(offsetParam: OffsetParam): void {
    Logger.debug(TAG, `onDidScroll: ${JSON.stringify(offsetParam)}`);
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    const isDark: boolean = AppStorage.get('systemColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const pageContext: PageContext = AppStorage.get('pageContext') as PageContext;
    // Calculate whether to display the sample category tabBar.
    if (offsetParam.tabIndex === TabBarType.SAMPLE) {
      const marginTop: number = globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT;
      const showTabOffset: number = this.state.bannerState.bannerHeight - marginTop;
      this.state.topNavigationData.showTab = (offsetParam.yOffset >= showTabOffset);
    }

    if (offsetParam.yOffset > this.state.bannerState.bannerHeight ||
      globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      if (offsetParam.breakpointChange) {
        this.state.topNavigationData.isBlur = true;
        if (offsetParam.tabIndex === AppStorage.get('currentTabIndex') && pageContext.navPathStack.size() === 1) {
          WindowUtil.updateStatusBarColor(getContext(), isDark);
        }
        TAB_CONTENT_STATUSES[offsetParam.tabIndex] = false;
        let colorData: number = 255;
        if (!isDark) {
          colorData = 0;
        }
        this.state.topNavigationData.titleColor = `rgba(${colorData},${colorData},${colorData}, 1)`;
      }
      if (offsetParam.yOffset >= CommonConstants.SPACE_8) {
        this.state.topNavigationData.isBlur = true;
      } else {
        this.state.topNavigationData.isBlur = false;
      }
      return;
    }

    if (offsetParam.yOffset === 0 && this.state.currentScrollState === 1) {
      this.bannerSpringBack();
    }
    const bannerHeight: number = this.state.bannerHeight -
      (CommonConstants.NAVIGATION_HEIGHT + globalInfoModel.statusBarHeight) * 2;
    const yOffset: number = Math.abs(offsetParam.yOffset || 0);
    let opacity: number = yOffset >= bannerHeight ? (yOffset - bannerHeight) / CommonConstants.NAVIGATION_HEIGHT : 0;
    if (opacity >= 1) {
      opacity = 1;
    }
    if (opacity > 0) {
      this.state.topNavigationData.isBlur = true;
      TAB_CONTENT_STATUSES[offsetParam.tabIndex] = false;
    } else {
      this.state.topNavigationData.isBlur = false;
      TAB_CONTENT_STATUSES[offsetParam.tabIndex] = true;
    }
    if (offsetParam.tabIndex === AppStorage.get('currentTabIndex') && pageContext.navPathStack.size() === 1) {
      WindowUtil.updateStatusBarColor(getContext(), opacity > 0 ? isDark : true);
    }
    let colorData: number = 255;
    if (!isDark) {
      colorData = 255 - opacity * 255;
    }
    this.state.topNavigationData.titleColor = `rgba(${colorData},${colorData},${colorData}, 1)`;
  }

  protected jumpBannerDetail(banner: BannerData): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    const pageContext: PageContext = AppStorage.get('pageContext') as PageContext;
    if (banner.bannerType === BannerTypeEnum.COMPONENT) {
      const componentPageContext: PageContext =
        globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('componentListPageContext')! :
          pageContext;
      const componentDetailParam: ComponentDetailParams = {
        componentName: banner.bannerTitle,
        componentId: Number(banner.bannerValue),
      };
      componentPageContext.openPage({
        routerName: 'ComponentDetailView',
        param: componentDetailParam,
      }, true);
    } else if (banner.bannerType === BannerTypeEnum.SAMPLE) {
      const samplePageContext: PageContext =
        globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('samplePageContext')! :
          pageContext;
      const sampleParam: SampleDetailParams = {
        currentIndex: 0,
        sampleCardId: Number(banner.bannerValue),
      };
      samplePageContext.openPage({
        routerName: 'SampleDetailView',
        param: sampleParam,
      }, true);

    } else if (banner.bannerType === BannerTypeEnum.ARTICLE) {
      // Get the current path stack.
      let currentPageContext: PageContext = pageContext;
      if (globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
        if (banner.tabViewType === TabBarType.HOME) {
          currentPageContext = AppStorage.get('componentListPageContext')!;
        } else if (banner.tabViewType === TabBarType.SAMPLE) {
          currentPageContext = AppStorage.get('samplePageContext')!;
        } else {
          currentPageContext = AppStorage.get('explorationPageContext')!;
        }
      }
      const articleParam: ArticleDetailParams = {
        id: Number(banner.bannerValue),
        title: banner.bannerTitle,
        detailsUrl: banner.detailsUrl,
        isArticle: false,
        tabViewType: globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ? banner.id : banner.tabViewType,
      };
      animateTo({ curve: curves.interpolatingSpring(0, 1, 273, 33) }, () => {
        currentPageContext.openPage({
          routerName: 'BannerDetailView',
          param: articleParam,
        }, false);
      });
    }
  }

  private bannerSpringBack() {
    this.state.currentScrollState = 2;
    animateTo({ curve: this.springBackAnimation, duration: 250 }, () => {
      this.changeBannerHeight();
      this.state.topNavigationData.titleOffsetY = 0;
      this.state.topNavigationData.titleScale = 1;
    });
  }
}

export interface CalculateHeightParam {
  yOffset: number;
  offset: number;
  state: ScrollState;
}

export interface OffsetParam {
  yOffset: number;
  tabIndex: number;
  breakpointChange?: boolean; // Indicates wether to process breakpoint change.
}

export enum BaseHomeEventType {
  JUMP_BANNER_DETAIL = 'jumpBannerDetail',
  HANDLE_SCROLL_OFFSET = 'handleScrollOffset',
  CALCULATE_BANNER_HEIGHT = 'calculateBannerHeight',
  CHANGE_BANNER_HEIGHT = 'changeBannerHeight',
  BANNER_SPRING_BACK = 'bannerSpringBack',
  HANDLE_BREAKPOINT_CHANGE = 'handleBreakpointChange',
  HANDLE_COLOR_CHANGE = 'handleColorModeChange',
}

export interface BaseHomeEventParam<T> {
  type: BaseHomeEventType;
  param: T;
}