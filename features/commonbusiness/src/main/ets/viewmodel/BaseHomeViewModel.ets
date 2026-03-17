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
import { curves, LengthMetrics } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { ScrollEffectType } from '@kit.UIDesignKit';
import { GlobalInfoModel, PageEnum } from '@ohos/common';
import {
  BaseVM,
  BreakpointType,
  CommonConstants,
  Logger,
  PageContext,
  ProductSeriesEnum,
  StatusBarColorType,
  StorageKey,
  VersionUtil,
  WindowUtil,
} from '@ohos/common';
import type { BannerData } from '../model/BannerData';
import { BANNER_SCALE_FACTOR, BannerTypeEnum, TITLE_SCALE_FACTOR } from '../model/BannerData';
import type { ArticleDetailParams, ComponentDetailParams, SampleDetailParams } from '../model/RouterParams';
import { TAB_CONTENT_STATUSES, TabBarType } from '../model/TabStatusBarModel';
import type { BaseHomeState } from './BaseHomeState';

const TAG = '[BaseHomeViewModel]';
const BANNER_HEIGHT_LG = 242;
const BANNER_CONTENT_HEIGHT = 160;
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
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    const isLargeWidth: boolean = (globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL);
    this.state.topNavigationData.bgColor =
      isLargeWidth ? $r('sys.color.background_secondary') : $r('sys.color.ohos_id_color_background_transparent');
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
    }).getValue(globalInfoModel.widthBreakpoint);
    this.state.bannerHeight = this.state.bannerState.bannerHeight;
    this.originBannerHeight = this.state.bannerHeight;
    this.setTitleBarStyle();
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
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    if (param.yOffset === 0) {
      this.state.hasEdgeEffect = false;
    } else {
      this.state.hasEdgeEffect = param.offset > 0;
    }
    if (globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL || param.yOffset > 0) {
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
    this.setTitleBarStyle();
    offsetParam.breakpointChange = true;
    this.handleListOffset(offsetParam);
  }

  protected handleColorModeChange(offsetParam: OffsetParam) {
    const pageContext = AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    if (pageContext && pageContext?.navPathStack.size() > 1) {
      return;
    }
    const isDark: boolean =
      AppStorage.get(StorageKey.COLOR_MODE) === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (isDark) {
      this.state.topNavigationData.titleColor = `rgba(255,255,255, 1)`;
    } else {
      offsetParam.breakpointChange = true;
      this.handleListOffset(offsetParam);
    }
  }

  protected changeBannerHeight(): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
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
    }).getValue(globalInfoModel.widthBreakpoint);
    this.state.bannerHeight = this.state.bannerState.bannerHeight;
    this.originBannerHeight = this.state.bannerHeight;
  }

  protected handleListOffset(offsetParam: OffsetParam): void {
    Logger.debug(TAG, `onDidScroll: ${JSON.stringify(offsetParam)}`);
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    const isDark: boolean =
      AppStorage.get(StorageKey.COLOR_MODE) === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const pageContext = AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    // Calculate whether to display the sample category tabBar.
    if (offsetParam.tabIndex === TabBarType.SAMPLE) {
      const marginTop: number = globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT;
      const showTabOffset: number = this.state.bannerState.bannerHeight - marginTop;
      this.state.topNavigationData.showTab = (offsetParam.yOffset >= showTabOffset);
      this.state.showTab = this.state.topNavigationData.showTab;
    }

    if (offsetParam.yOffset > this.state.bannerState.bannerHeight ||
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) {
      if (offsetParam.breakpointChange) {
        this.state.topNavigationData.isBlur = true;
        if (!VersionUtil.canUseHds() && offsetParam.tabIndex === AppStorage.get(StorageKey.CURRENT_TAB) &&
          pageContext?.navPathStack?.size() === 1) {
          WindowUtil.updateStatusBarColor(isDark);
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

    if (offsetParam.yOffset === 0 && this.state.currentScrollState === ScrollState.Scroll) {
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
    if (!VersionUtil.canUseHds() && offsetParam.tabIndex === AppStorage.get(StorageKey.CURRENT_TAB) &&
      pageContext?.navPathStack?.size() === 1) {
      WindowUtil.updateStatusBarColor(opacity > 0 ? isDark : true);
    }
    let colorData: number = 255;
    if (!isDark) {
      colorData = 255 - opacity * 255;
    }
    this.state.topNavigationData.titleColor = `rgba(${colorData},${colorData},${colorData}, 1)`;
  }

  protected jumpBannerDetail(banner: BannerData): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    const pageContext = AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    if (banner.type === BannerTypeEnum.COMPONENT) {
      const componentPageContext = globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        AppStorage.get<PageContext>(StorageKey.COMPONENT_PAGE_CONTEXT) : pageContext;
      const componentDetailParam: ComponentDetailParams = {
        componentName: banner.title,
        id: Number(banner.value) ?? 0,
        contentType: banner.contentType,
      };
      componentPageContext?.openPage({
        routerName: PageEnum.COMPONENT_DETAIL_VIEW,
        param: componentDetailParam,
      }, true);
    } else if (banner.type === BannerTypeEnum.SAMPLE) {
      const samplePageContext = globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        AppStorage.get<PageContext>(StorageKey.SAMPLE_PAGE_CONTEXT) : pageContext;
      const sampleParam: SampleDetailParams = {
        currentIndex: 0,
        cardId: 0,
        contentType: banner.contentType,
        unionId: 0,
        id: Number(banner.value),
      };
      samplePageContext?.openPage({
        routerName: PageEnum.SAMPLE_DETAIL_VIEW,
        param: sampleParam,
      }, true);

    } else if (banner.type === BannerTypeEnum.ARTICLE) {
      // Get the current path stack.
      let currentPageContext = pageContext;
      if (globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) {
        if (banner.tabViewType === TabBarType.HOME) {
          currentPageContext = AppStorage.get<PageContext>(StorageKey.COMPONENT_PAGE_CONTEXT);
        } else if (banner.tabViewType === TabBarType.SAMPLE) {
          currentPageContext = AppStorage.get<PageContext>(StorageKey.SAMPLE_PAGE_CONTEXT);
        } else {
          currentPageContext = AppStorage.get<PageContext>(StorageKey.EXPLORATION_PAGE_CONTEXT);
        }
      }
      const articleParam: ArticleDetailParams = {
        id: Number(banner.value),
        title: banner.title,
        detailsUrl: banner.detailsUrl,
        isArticle: false,
        contentType: banner.contentType,
        tabViewType: globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? banner.id : banner.tabViewType,
      };
      const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
      uiContext?.animateTo({ curve: curves.interpolatingSpring(0, 1, 273, 33) }, () => {
        currentPageContext?.openPage({
          routerName: PageEnum.BANNER_DETAIL_VIEW,
          param: articleParam,
        }, false);
      });
    }
  }

  private bannerSpringBack() {
    this.state.currentScrollState = ScrollState.Fling;
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    uiContext?.animateTo({ curve: this.springBackAnimation, duration: 250 }, () => {
      this.changeBannerHeight();
      this.state.topNavigationData.titleOffsetY = 0;
      this.state.topNavigationData.titleScale = 1;
    });
  }

  protected setTitleBarStyle(dataFailed?: boolean) {
    if (VersionUtil.canUseHds()) {
      const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
      this.state.topNavigationData.hdsTitleBarPadding = {
        start:
        LengthMetrics.vp(new BreakpointType<number>({
          sm: CommonConstants.SPACE_16,
          md: CommonConstants.SPACE_24,
          lg: CommonConstants.SPACE_32 + CommonConstants.TAB_BAR_WIDTH,
          xl: CommonConstants.SPACE_32,
        }).getValue(globalInfoModel.widthBreakpoint)),
        end:
        LengthMetrics.vp(new BreakpointType<number>({
          sm: CommonConstants.SPACE_16,
          md: CommonConstants.SPACE_24,
          lg: CommonConstants.SPACE_32,
          xl: CommonConstants.SPACE_32,
        }).getValue(globalInfoModel.widthBreakpoint)),
      };
      this.state.topNavigationData.hdsTitleBarStyle = {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.COMMON_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(new BreakpointType<number>({
            sm: this.state.bannerHeight - BANNER_CONTENT_HEIGHT - globalInfoModel.statusBarHeight,
            md: this.state.bannerHeight - BANNER_CONTENT_HEIGHT - globalInfoModel.statusBarHeight,
            lg: 0,
            xl: 0,
          }).getValue(globalInfoModel.widthBreakpoint)),
          blurEffectiveEndOffset: LengthMetrics.vp(new BreakpointType<number>({
            sm: this.state.bannerHeight - globalInfoModel.statusBarHeight - CommonConstants.NAVIGATION_HEIGHT,
            md: this.state.bannerHeight - globalInfoModel.statusBarHeight - CommonConstants.NAVIGATION_HEIGHT,
            lg: CommonConstants.NAVIGATION_HEIGHT,
            xl: CommonConstants.NAVIGATION_HEIGHT,
          }).getValue(globalInfoModel.widthBreakpoint)),
        },
        originalStyle: {
          contentStyle: {
            titleStyle: {
              mainTitleColor: dataFailed ? $r('sys.color.font_primary') :
                new BreakpointType<ResourceColor>({
                  sm: $r('sys.color.font_on_primary'),
                  md: $r('sys.color.font_on_primary'),
                  lg: $r('sys.color.font_primary')
                }).getValue(globalInfoModel.widthBreakpoint),
            },
          },
        },
        scrollEffectStyle: {
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('sys.color.font_primary'),
            },
          },
        },
      };
    }
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