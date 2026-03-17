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
import { SymbolGlyphModifier } from '@kit.ArkUI';
import {
  HdsNavDestination,
  HdsNavDestinationAttribute,
  HdsSideBar,
  HdsTabs,
  HdsTabsAttribute,
  DividerMode,
  HdsTabsController,
} from '@kit.UIDesignKit';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  Logger,
  ProcessUtil,
  StorageKey,
  Toast,
  VersionUtil,
  WantParams,
  WindowUtil
} from '@ohos/common';
import { TAB_CONTENT_STATUSES, TabBarType } from '@ohos/commonbusiness';
import { ComponentListView } from '@ohos/componentlibrary';
import { PracticesView } from '@ohos/devpractices';
import { ExplorationView } from '@ohos/exploration';
import { MineView } from '@ohos/mine';
import { CustomSideBar } from '../component/CustomSideBar';
import { CustomTabBar } from '../component/CustomTabBar';
import { TABS_LIST } from '../model/TabBarModel';
import { HomeEventTypeEnum, MainPageViewModel } from '../viewmodel/MainPageViewModel';

const PRESS_TIME: number = 1500;
const TAG: string = '[MainPage]';

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component({ freezeWhenInactive: true })
struct MainPage {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @State currentIndex: number = 0;
  private tabController: TabsController | HdsTabsController =
    VersionUtil.canUseHds() ? new HdsTabsController() : new TabsController();
  private backPressTime: number = 0;
  private isShown: boolean = false;
  private mainPageViewModel: MainPageViewModel = new MainPageViewModel();
  private componentScroller: Scroller = new Scroller();
  private sampleScroller: Scroller = new Scroller();
  private articleScroller: Scroller = new Scroller();
  private mineScroller: Scroller = new Scroller();

  @Builder
  TabContentsBuilder(showTabBar: boolean) {
    TabContent() {
      ComponentListView({ scroller: this.componentScroller })
    }
    .tabBar(showTabBar ? this.bottomTabBarStyle(TabBarType.HOME) : new SubTabBarStyle(''))

    TabContent() {
      PracticesView({ listScroller: this.sampleScroller })
    }
    .tabBar(showTabBar ? this.bottomTabBarStyle(TabBarType.SAMPLE) : new SubTabBarStyle(''))

    TabContent() {
      ExplorationView({ scroller: this.articleScroller })
    }
    .tabBar(showTabBar ? this.bottomTabBarStyle(TabBarType.PRACTICE) : new SubTabBarStyle(''))

    TabContent() {
      MineView({ scroller: this.mineScroller })
    }
    .tabBar(showTabBar ? this.bottomTabBarStyle(TabBarType.MINE) : new SubTabBarStyle(''))
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate(StorageKey.CURRENT_TAB, 0);
    if (VersionUtil.canUseHds()) {
      const hdsTabController: HdsTabsController = this.tabController as HdsTabsController;
      hdsTabController.bindScroller(TabBarType.HOME, this.componentScroller);
      hdsTabController.bindScroller(TabBarType.SAMPLE, this.sampleScroller);
      hdsTabController.bindScroller(TabBarType.PRACTICE, this.articleScroller);
      hdsTabController.bindScroller(TabBarType.MINE, this.mineScroller);
    }
  }

  onPageShow(): void {
    this.isShown = true;
    this.handleColorModeChange();
    CommonConstants.PROMISE_WAIT(500).then(() => {
      AppStorage.setOrCreate(StorageKey.BLUE_RENDER_GROUP, false);
    });
    const wantParams: WantParams | undefined = AppStorage.get<WantParams>(StorageKey.WANT_PARAMETERS);
    AppStorage.delete(StorageKey.WANT_PARAMETERS);
    if (wantParams) {
      const tabIndex: number = this.mainPageViewModel.sendEvent<WantParams>({
        type: HomeEventTypeEnum.JUMP_TO_PAGE,
        param: wantParams,
      }) as number;
      this.currentIndex = tabIndex;
    }
    this.changeTabStatus(this.currentIndex);
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
      this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) {
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
    return BottomTabBarStyle.of({ normal: new SymbolGlyphModifier(tabItem.icon) }, tabItem.title)
      .padding({
        bottom: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? 0 :
          this.globalInfoModel.naviIndicatorHeight
      })
  }

  @Builder
  HdsTabComponent() {
    HdsTabs({ controller: this.tabController as HdsTabsController, index: this.currentIndex }) {
      this.TabContentsBuilder(this.globalInfoModel.widthBreakpoint !== WidthBreakpoint.WIDTH_XL)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .vertical(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG)
    .barPosition(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? BarPosition.Start :
      BarPosition.End)
    .divider({
      mode: DividerMode.FOLLOW_SCROLL,
    })
    .barHeight(new BreakpointType<Length>({
      sm: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight,
      md: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight,
      lg: '100%',
      xl: 0,
    }).getValue(this.globalInfoModel.widthBreakpoint))
    .barOverlap(true)
    .scrollable(false)
    .onAttach(() => {
      this.tabController?.preloadItems([TabBarType.HOME, TabBarType.SAMPLE, TabBarType.PRACTICE])
        .catch((error: Error) => {
          Logger.error(TAG, `onAttach failed. cause: ${error.message}`);
        });
    })
    .onChange((index: number) => {
      this.changeTabStatus(index);
    })
  }

  @Builder
  CustomSideBarBuilder() {
    CustomSideBar({
      currentIndex: this.currentIndex,
      sideBarChange: (currentIndex: number) => {
        this.changeTabStatus(currentIndex);
      }
    })
  }

  @Builder
  TabComponent() {
    Tabs({ controller: this.tabController, index: this.currentIndex }) {
      this.TabContentsBuilder(false)
    }
    .onAttach(() => {
      this.tabController.preloadItems([TabBarType.HOME, TabBarType.SAMPLE, TabBarType.PRACTICE])
        .catch((error: Error) => {
          Logger.error(TAG, `onAttach failed. cause: ${error.message}`);
        })
    })
    .onAnimationStart((index: number, targetIndex: number) => {
      this.changeTabStatus(targetIndex);
    })
    .animationMode(AnimationMode.NO_ANIMATION)
    .barWidth(0)
    .barHeight(0)
    .scrollable(false)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    if (VersionUtil.canUseHds()) {
      HdsNavDestination() {
        HdsSideBar({
          isShowSideBar: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL,
          autoHide: false,
          sideBarPanelBuilder: () => {
            this.CustomSideBarBuilder()
          },
          contentPanelBuilder: () => {
            this.HdsTabComponent()
          },
          minContentWidth: 0,
        })
      }
      .transition(TransitionEffect.OPACITY)
      .hideTitleBar(true)
      .backgroundColor($r('sys.color.background_secondary'))
      .onBackPressed(() => {
        return this.onBackPress();
      })
      .onShown(() => {
        this.onPageShow();
      })
      .onHidden(() => {
        AppStorage.setOrCreate(StorageKey.BLUE_RENDER_GROUP, true);
        this.isShown = false;
      })
      .height('100%')
      .width('100%')
    } else {
      NavDestination() {
        SideBarContainer(SideBarContainerType.Embed) {
          this.CustomSideBarBuilder()
          Stack({ alignContent: Alignment.BottomStart }) {
            this.TabComponent()
            CustomTabBar({
              currentIndex: this.currentIndex, tabBarChange: (currentIndex: number) => {
                this.changeTabStatus(currentIndex);
                this.currentIndex = currentIndex;
              }
            })
              .visibility(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? Visibility.None :
                Visibility.Visible)
          }
        }
        .autoHide(false)
        .showSideBar(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL)
        .showControlButton(false)
      }
      .transition(TransitionEffect.OPACITY)
      .hideTitleBar(true)
      .backgroundColor($r('sys.color.background_secondary'))
      .onBackPressed(() => {
        return this.onBackPress();
      })
      .onShown(() => {
        this.onPageShow();
      })
      .onHidden(() => {
        AppStorage.setOrCreate(StorageKey.BLUE_RENDER_GROUP, true);
        this.isShown = false;
      })
      .height('100%')
      .width('100%')
    }
  }
}