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

import type { common } from '@kit.AbilityKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { SymbolGlyphModifier, TabsModifier } from '@kit.ArkUI';
import {
  HdsTabs, DividerMode, HdsTabsController, hdsMaterial, HdsTabsModifier,
} from '@kit.UIDesignKit';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  HdsUtil,
  Logger,
  MainTabEnum,
  ProcessUtil,
  PullUpManager,
  PushServiceManager,
  StorageKey,
  Toast,
  WantParams,
  WindowUtil,
  TrackEventType,
  TrackManager,
  TrackServiceData,
  AlertDialog,
} from '@ohos/common';
import { TAB_CONTENT_STATUSES, TabBarType } from '@ohos/commonbusiness';
import { ComponentHomeView } from '@ohos/componentlibrary';
import { PracticeHomeView } from '@ohos/devpractices';
import { ExplorationHomeView } from '@ohos/exploration';
import { MineHomeView } from '@ohos/mine';
import { TABS_LIST } from '../model/TabBarModel';
import { HomeEventTypeEnum, MainPageViewModel } from '../viewmodel/MainPageViewModel';

const PRESS_TIME: number = 1500;
const TAG: string = '[HomeView]';

@Component
export struct HomeView {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @StorageProp(StorageKey.WANT_PARAMETERS) @Watch('jumpPage') wantParams: WantParams | undefined =
    AppStorage.get<WantParams>(StorageKey.WANT_PARAMETERS);
  @Prop showTabBar: boolean = false;
  @Prop isShown: boolean = false;
  @Link currentIndex: number;
  @State tabsModifier: TabsModifier | HdsTabsModifier =
    (HdsUtil.isSupportNewMaterialApi() ? new HdsTabsModifier() : new TabsModifier());
  private tabController: HdsTabsController = new HdsTabsController();
  private backPressTime: number = 0;
  private mainPageViewModel: MainPageViewModel = new MainPageViewModel();
  private componentScroller: Scroller = new Scroller();
  private sampleScroller: Scroller = new Scroller();
  private articleScroller: Scroller = new Scroller();
  private mineScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const uiContext: UIContext | undefined = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    if (uiContext) {
      const context: Context | undefined = uiContext?.getHostContext();
      if (context) {
        PushServiceManager.getInstance().initPushServiceManager(context);
      }
    }
    AppStorage.setOrCreate(StorageKey.CURRENT_TAB, 0);

    if (HdsUtil.isSupportNewMaterialApi() && !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
      (this.tabsModifier as HdsTabsModifier)
        .vertical(false)
        .barPosition(BarPosition.End)
        .barHeight(this.showTabBar ? CommonConstants.TAB_BAR_HEIGHT : 0)
        .barFloatingStyle({
          adaptToHandedness: true,
          barBottomMargin: this.globalInfoModel.naviIndicatorHeight,
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.IMMERSIVE,
            materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
          },
        })
    }
    this.tabController.bindScroller(TabBarType.HOME, this.componentScroller);
    this.tabController.bindScroller(TabBarType.SAMPLE, this.sampleScroller);
    this.tabController.bindScroller(TabBarType.PRACTICE, this.articleScroller);
    this.tabController.bindScroller(TabBarType.MINE, this.mineScroller);
  }

  onPageShow(): void {
    this.isShown = true;
    this.handleColorModeChange();
    CommonConstants.PROMISE_WAIT(500).then(() => {
      AppStorage.setOrCreate(StorageKey.BLUE_RENDER_GROUP, false);
    });
  }

  jumpPage(): void {
    if (this.wantParams) {
      PullUpManager.navigationToHome();
      const tabIndex: number = this.mainPageViewModel.sendEvent<WantParams>({
        type: HomeEventTypeEnum.JUMP_TO_PAGE,
        param: this.wantParams,
      }) as number;
      this.currentIndex = tabIndex;
      this.changeTabStatus(this.currentIndex);
      /* for unknown reason,
          // AppStorage.delete(StorageKey.WANT_PARAMETERS);
        doesn't works properly... Until the reason is found out,
        we use .setOrCreate(_, undefined); as a temp replacement.
       */
      AppStorage.setOrCreate(StorageKey.WANT_PARAMETERS, undefined);
      // We expect to change it back after finding out the reason...
      if (AppStorage.get(StorageKey.XIAOYI_EXTRACTED_NO_PARAM)) {
        // if xiaoyi extracted nothing, give some hint to user...
        AppStorage.set(StorageKey.XIAOYI_EXTRACTED_NO_PARAM, undefined);
        Logger.info(TAG, `AlertDialog.showAlertDialogWhenXiaoYiFailed()`);
        AlertDialog.showAlertDialogWhenXiaoYiFailed(this.getUIContext());
      }
    }
  }

  onBackPress(): boolean {
    const newTime = new Date().getTime();
    if (this.backPressTime && newTime - this.backPressTime < PRESS_TIME) {
      ProcessUtil.moveAbilityToBackground(this.getUIContext().getHostContext() as common.UIAbilityContext);
      return true;
    }
    this.backPressTime = newTime;
    Toast.showToast($r('app.string.back_toast'));
    return true;
  }

  changeTabStatus(index: number) {
    AppStorage.setOrCreate(StorageKey.CURRENT_TAB, index);
    const selectedIndex = index;
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    if (selectedIndex === TabBarType.MINE || this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ||
    AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
      WindowUtil.updateStatusBarColor(isSystemDark);
    } else {
      WindowUtil.updateStatusBarColor(isSystemDark || TAB_CONTENT_STATUSES[selectedIndex]);
    }
    this.currentIndex = index;
  }

  handleColorModeChange() {
    if (this.isShown) {
      this.changeTabStatus(this.currentIndex);
    }
  }

  bottomTabBarStyle(tabType: TabBarType): BottomTabBarStyle {
    const tabItem = TABS_LIST[tabType];
    const normalGlyphModifier = new SymbolGlyphModifier(tabItem.icon)
      .renderingStrategy(HdsUtil.isSupportNewMaterialApi() ? SymbolRenderingStrategy.SINGLE :
        SymbolRenderingStrategy.MULTIPLE_OPACITY);
    if (HdsUtil.isSupportNewMaterialApi()) {
      normalGlyphModifier.fontColor(HdsUtil.isSupportNewMaterialApi() ? [$r('sys.color.icon_primary')] : [])
    }
    return BottomTabBarStyle.of({
      normal: normalGlyphModifier,
      selected: new SymbolGlyphModifier(tabItem.icon)
        .renderingStrategy(HdsUtil.isSupportNewMaterialApi() ? SymbolRenderingStrategy.SINGLE :
          SymbolRenderingStrategy.MULTIPLE_OPACITY)
    }, tabItem.title)
      .labelStyle(HdsUtil.isSupportNewMaterialApi() ? { unselectedColor: $r('sys.color.font_primary') } : undefined)
      .padding({
        bottom: (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
        HdsUtil.isSupportNewMaterialApi()) ? 0 : this.globalInfoModel.naviIndicatorHeight
      })
  }

  reportTrackData(tabIndex: TabBarType): void {
    let mainTab: MainTabEnum;
    switch (tabIndex) {
      case TabBarType.HOME:
        mainTab = MainTabEnum.COMPONENT;
        break;
      case TabBarType.SAMPLE:
        mainTab = MainTabEnum.SAMPLE;
        break;
      case TabBarType.PRACTICE:
        mainTab = MainTabEnum.ARTICLE;
        break;
      case TabBarType.MINE:
        mainTab = MainTabEnum.MINE;
        break;
      default:
        mainTab = MainTabEnum.COMPONENT;
        break;
    }
    TrackManager.getInstance().reportData({
      eventType: TrackEventType.CLICK,
      mainTab,
    } as TrackServiceData)
  }

  @Builder
  TabContentsBuilder() {
    TabContent() {
      ComponentHomeView({ scroller: this.componentScroller, homeTabController: this.tabController })
    }
    .tabBar(this.showTabBar ? this.bottomTabBarStyle(TabBarType.HOME) : new SubTabBarStyle(''))

    TabContent() {
      PracticeHomeView({ scroller: this.sampleScroller, homeTabController: this.tabController })
    }
    .tabBar(this.showTabBar ? this.bottomTabBarStyle(TabBarType.SAMPLE) : new SubTabBarStyle(''))

    TabContent() {
      ExplorationHomeView({ scroller: this.articleScroller, homeTabController: this.tabController })
    }
    .tabBar(this.showTabBar ? this.bottomTabBarStyle(TabBarType.PRACTICE) : new SubTabBarStyle(''))

    TabContent() {
      MineHomeView({ scroller: this.mineScroller, homeTabController: this.tabController })
    }
    .tabBar(this.showTabBar ? this.bottomTabBarStyle(TabBarType.MINE) : new SubTabBarStyle(''))
  }

  build() {
    HdsTabs({ controller: this.tabController as HdsTabsController, index: this.currentIndex }) {
      this.TabContentsBuilder()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .vertical((this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) &&
      !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT))
    .barPosition((this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) &&
      !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? BarPosition.Start :
      BarPosition.End)
    .divider({
      mode: !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? DividerMode.FOLLOW_SCROLL : DividerMode.NONE,
    })
    .barHeight(this.showTabBar ? new BreakpointType<Length>({
      sm: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight,
      md: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight,
      lg: '100%',
    }).getValue(this.globalInfoModel.widthBreakpoint) : 0)
    .barOverlap(true)
    .scrollable(false)
    .animationDuration(0)
    .attributeModifier(HdsUtil.isSupportNewMaterialApi() ? this.tabsModifier as HdsTabsModifier : undefined)
    .onAttach(() => {
      this.tabController?.preloadItems([TabBarType.HOME, TabBarType.SAMPLE, TabBarType.PRACTICE])
        .then(()=>{
          this.jumpPage();
        })
        .catch((error: Error) => {
          Logger.error(TAG, `onAttach failed. cause: ${error.message}`);
        });
    })
    .onChange((index: number) => {
      this.reportTrackData(index);
      this.changeTabStatus(index);
    })
  }
}