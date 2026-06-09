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

import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { curves, LengthMetrics } from '@kit.ArkUI';
import {
  HdsAnimationMode,
  hdsMaterial,
  HdsTabsController,
  ScrollEffectOptions,
  ScrollEffectType,
  TitleBarStyleOptions,
} from '@kit.UIDesignKit';
import {
  BaseVM,
  BreakpointType,
  CommonConstants,
  Logger,
  PageContext,
  StorageKey,
  HdsUtil,
  GlobalInfoModel,
  InteractionTypeEnum,
  PageEnum,
  ProcessUtil,
  Toast,
} from '@ohos/common';
import type { BannerData } from '../model/BannerData';
import { BANNER_SCALE_FACTOR, BannerTypeEnum } from '../model/BannerData';
import type { ArticleDetailParams, ComponentDetailParams, SampleDetailParams } from '../model/RouterParams';
import { TAB_CONTENT_STATUSES, TabBarType } from '../model/TabStatusBarModel';
import type { BaseHomeState } from './BaseHomeState';

const TAG = '[BaseHomeViewModel]';
const BANNER_HEIGHT_LG = 242;
const BANNER_HEIGHT_XL = 260;
const BANNER_CONTENT_HEIGHT = 160;
const PRESS_TIME: number = 1500;

@Observed
export class BaseHomeViewModel<T extends BaseHomeState> extends BaseVM<BaseHomeState> {
  protected state: T;
  protected readonly pageSize: number = 30;
  protected homeTabController: HdsTabsController = new HdsTabsController();
  private isScrollUp: boolean = false;
  private originBannerHeight: number = 0;
  private springBackAnimation: curves.ICurve = curves.interpolatingSpring(0, 1, 288, 30);
  private backPressTime: number = 0;

  public constructor(initialState: T) {
    super(initialState);
    this.state = initialState;
    this.changeBannerHeight();
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
    } else if (eventType === BaseHomeEventType.HANDLE_TAB_BAR_ANIMATION) {
      return this.handleTabBarAnimation(eventParam.param as TabBarAnimationParam);
    } else if (eventType === BaseHomeEventType.INITIALIZE) {
      return this.initialize(eventParam.param as InitializeParam);
    } else if (eventType === BaseHomeEventType.ON_BACK_PRESS) {
      return this.onBackPress();
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
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ||
      AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) || param.yOffset > 0) {
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
    this.handleTabBarAnimation({ yOffset: -1, tabIndex: offsetParam.tabIndex });
  }

  protected handleColorModeChange(offsetParam: OffsetParam) {
    const pageContext = AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    if (pageContext && pageContext?.navPathStack.size() > 1) {
      return;
    }
    const isDark: boolean =
      AppStorage.get(StorageKey.COLOR_MODE) === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (!isDark) {
      offsetParam.breakpointChange = true;
      this.handleListOffset(offsetParam);
    }
  }

  protected changeBannerHeight(): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    const naviTitleHeight: number =
      globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT + CommonConstants.SPACE_8;
    let defaultBannerHeight: number = BANNER_HEIGHT_LG + naviTitleHeight;
    this.state.bannerState.bannerHeight =
      AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? BANNER_HEIGHT_XL + naviTitleHeight : new BreakpointType({
        sm: globalInfoModel.aspectRatio < CommonConstants.ASPECT_SQUARE_PORTRAIT &&
          globalInfoModel.aspectRatio > CommonConstants.ASPECT_PORTRAIT_NARROW ?
          CommonConstants.BANNER_ASPECT_PORTRAIT * globalInfoModel.deviceWidth :
          CommonConstants.BANNER_ASPECT_SM * globalInfoModel.deviceWidth,
        md: CommonConstants.BANNER_ASPECT_MD * globalInfoModel.deviceWidth,
        lg: defaultBannerHeight,
        xl: defaultBannerHeight,
      }).getValue(globalInfoModel.widthBreakpoint);
    this.state.bannerHeight = this.state.bannerState.bannerHeight;
    this.originBannerHeight = this.state.bannerHeight;
  }

  protected handleListOffset(offsetParam: OffsetParam): void {
    Logger.debug(TAG, `onDidScroll: ${JSON.stringify(offsetParam)}`);
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    // Calculate whether to display the sample category tabBar.
    if (offsetParam.tabIndex === TabBarType.SAMPLE) {
      const marginTop: number = globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT;
      const showTabOffset: number = this.state.bannerState.bannerHeight - marginTop;
      this.state.showTab = (offsetParam.yOffset >= showTabOffset);
    }

    if (offsetParam.yOffset > this.state.bannerState.bannerHeight ||
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ||
      AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
      if (offsetParam.breakpointChange) {
        TAB_CONTENT_STATUSES[offsetParam.tabIndex] = false;
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
    if (opacity > 0) {
      TAB_CONTENT_STATUSES[offsetParam.tabIndex] = false;
    } else {
      TAB_CONTENT_STATUSES[offsetParam.tabIndex] = true;
    }
  }

  protected jumpBannerDetail(banner: BannerData): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    const pageContext = AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    if (banner.type === BannerTypeEnum.COMPONENT) {
      const componentPageContext = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
        AppStorage.get<PageContext>(StorageKey.COMPONENT_PAGE_CONTEXT) : pageContext;
      const componentDetailParam: ComponentDetailParams = {
        title: banner.title,
        id: Number(banner.value) ?? 0,
        interactionType: InteractionTypeEnum.COMPONENT,
      };
      componentPageContext?.openPage({
        routerName: PageEnum.COMPONENT_DETAIL_VIEW,
        param: componentDetailParam,
      }, true);
    } else if (banner.type === BannerTypeEnum.SAMPLE) {
      const samplePageContext = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
        AppStorage.get<PageContext>(StorageKey.SAMPLE_PAGE_CONTEXT) : pageContext;
      const sampleParam: SampleDetailParams = {
        title: banner.title,
        currentIndex: 0,
        cardId: 0,
        interactionType: InteractionTypeEnum.SAMPLE,
        unionId: 0,
        id: Number(banner.value),
        categoryName: '',
      };
      samplePageContext?.openPage({
        routerName: PageEnum.SAMPLE_DETAIL_VIEW,
        param: sampleParam,
      }, true);

    } else if (banner.type === BannerTypeEnum.ARTICLE) {
      // Get the current path stack.
      let currentPageContext = pageContext;
      if (AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
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
        desc: banner.desc,
        detailsUrl: banner.detailsUrl,
        isArticle: false,
        interactionType: InteractionTypeEnum.SAMPLE,
        tabViewType: (globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
          globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ||
          AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) ? banner.id : banner.tabViewType,
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
    });
  }

  protected handleTabBarAnimation(param: TabBarAnimationParam): void {
    if (!HdsUtil.isSupportNewMaterialApi() || AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ||
      param.tabIndex !== AppStorage.get<number>(StorageKey.CURRENT_TAB)) {
      return;
    }
    try {
      const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
      if (globalInfoModel.needDynamicHideBar) {
        if (param.yOffset > 0 && !this.isScrollUp) {
          this.isScrollUp = true;
          this.homeTabController?.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
          AppStorage.setOrCreate<boolean>('TabBarHidden', true);
        } else if (param.yOffset < 0 && this.isScrollUp) {
          this.isScrollUp = false;
          this.homeTabController?.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
          AppStorage.setOrCreate<boolean>('TabBarHidden', false);
        }
      } else if (AppStorage.get<boolean>('TabBarHidden')) {
        this.isScrollUp = false;
        this.homeTabController?.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
        AppStorage.setOrCreate<boolean>('TabBarHidden', false);
      }
    } catch (error) {
      Logger.error(TAG, `handleTabBarAnimation failed. cause ${error.message}`);
    }
  }

  protected initialize(param: InitializeParam): void {
    this.homeTabController = param.homeTabController;
    this.state.scroller = param.scroller ?? new Scroller();
  }

  protected setTitleBarStyle(dataFailed?: boolean) {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    this.state.topNavigationData.hdsTitleBarPadding = {
      start:
      LengthMetrics.vp(new BreakpointType<number>({
        sm: CommonConstants.SPACE_16,
        md: CommonConstants.SPACE_24,
        lg: (HdsUtil.isSupportNewMaterialApi() || AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) ?
          CommonConstants.SPACE_32 : CommonConstants.SPACE_32 + CommonConstants.TAB_BAR_WIDTH,
      }).getValue(globalInfoModel.widthBreakpoint)),
      end:
      LengthMetrics.vp(new BreakpointType<number>({
        sm: CommonConstants.SPACE_16,
        md: CommonConstants.SPACE_24,
        lg: CommonConstants.SPACE_32,
        xl: CommonConstants.SPACE_32,
      }).getValue(globalInfoModel.widthBreakpoint)),
    };
    const scrollEffectOpts: ScrollEffectOptions = {
      enableScrollEffect: true,
      scrollEffectType: ScrollEffectType.COMMON_BLUR,
      blurEffectiveStartOffset: LengthMetrics.vp(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? 0 :
        new BreakpointType<number>({
          sm: this.state.bannerHeight - BANNER_CONTENT_HEIGHT - globalInfoModel.statusBarHeight,
          md: this.state.bannerHeight - BANNER_CONTENT_HEIGHT - globalInfoModel.statusBarHeight,
          lg: 0,
          xl: 0,
        }).getValue(globalInfoModel.widthBreakpoint)),
      blurEffectiveEndOffset: LengthMetrics.vp(this.state.bannerHeight - globalInfoModel.statusBarHeight -
        CommonConstants.NAVIGATION_HEIGHT),
    }
    const hdsTitleBarStyle: TitleBarStyleOptions = {
      originalStyle: {
        contentStyle: {
          titleStyle: {
            mainTitleColor: (dataFailed || AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) ?
              $r('sys.color.font_primary') :
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
    if (HdsUtil.isSupportNewMaterialApi()) {
      hdsTitleBarStyle.systemMaterialEffect = {
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
      };
      scrollEffectOpts.scrollEffectType = ScrollEffectType.IMMERSIVE_GRADIENT_BLUR;
    }
    hdsTitleBarStyle.scrollEffectOpts = scrollEffectOpts;
    this.state.topNavigationData.hdsTitleBarStyle = hdsTitleBarStyle;
  }

  protected onBackPress(): boolean {
    const newTime = new Date().getTime();
    if (this.backPressTime && newTime - this.backPressTime < PRESS_TIME) {
      const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
      ProcessUtil.moveAbilityToBackground(uiContext?.getHostContext() as common.UIAbilityContext);
      return true;
    }
    this.backPressTime = newTime;
    Toast.showToast($r('app.string.back_toast'));
    return true;
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

export interface TabBarAnimationParam {
  yOffset: number;
  tabIndex: number;
}

export interface InitializeParam {
  homeTabController: HdsTabsController;
  scroller?: Scroller;
}

export enum BaseHomeEventType {
  JUMP_BANNER_DETAIL = 'jumpBannerDetail',
  HANDLE_SCROLL_OFFSET = 'handleScrollOffset',
  CALCULATE_BANNER_HEIGHT = 'calculateBannerHeight',
  CHANGE_BANNER_HEIGHT = 'changeBannerHeight',
  BANNER_SPRING_BACK = 'bannerSpringBack',
  HANDLE_BREAKPOINT_CHANGE = 'handleBreakpointChange',
  HANDLE_COLOR_CHANGE = 'handleColorModeChange',
  HANDLE_TAB_BAR_ANIMATION = 'handleTabBarAnimation',
  INITIALIZE = 'initialize',
  ON_BACK_PRESS = 'onBackPress',
}

export interface BaseHomeEventParam<T> {
  type: BaseHomeEventType;
  param: T;
}