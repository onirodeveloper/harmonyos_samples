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
import { promptAction } from '@kit.ArkUI';
import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointTypeEnum, CommonConstants, ProcessUtil, WindowUtil } from '@ohos/common';
import { TAB_CONTENT_STATUSES, TabBarType } from '@ohos/commonbusiness';
import { ComponentListView } from '@ohos/componentlibrary';
import { PracticesView } from '@ohos/devpractices';
import { ExplorationView } from '@ohos/exploration';
import { MineView } from '@ohos/mine';
import { CustomSideBar } from '../component/CustomSideBar';
import { CustomTabBar } from '../component/CustomTabBar';

const PRESS_TIME = 1500;

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component({ freezeWhenInactive: true })
struct MainPage {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @StorageProp('systemColorMode') @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get('systemColorMode')!;
  @State currentIndex: number = 0;
  private tabController: TabsController = new TabsController();
  private backPressTime: number = 0;
  private isShown: boolean = false;

  @Builder
  TabComponent() {
    Tabs({ controller: this.tabController, index: this.currentIndex }) {
      TabContent() {
        ComponentListView()
      }
      .height('100%')

      TabContent() {
        PracticesView()
      }
      .height('100%')

      TabContent() {
        ExplorationView()
      }
      .height('100%')

      TabContent() {
        MineView()
      }
      .height('100%')
    }
    .onAttach(() => {
      this.tabController.preloadItems([TabBarType.HOME, TabBarType.SAMPLE, TabBarType.PRACTICE])
    })
    .onAnimationStart((index: number, targetIndex: number) => {
      this.changeTabStatus(targetIndex);
      this.currentIndex = targetIndex;
    })
    .animationMode(AnimationMode.NO_ANIMATION)
    .barWidth(0)
    .barHeight(0)
    .scrollable(false)
    .backgroundColor($r('sys.color.background_secondary'))
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('currentTabIndex', 0);
  }

  onBackPress(): boolean {
    const newTime = new Date().getTime();
    if (this.backPressTime && newTime - this.backPressTime < PRESS_TIME) {
      ProcessUtil.moveAbilityToBackground(getContext(this) as common.UIAbilityContext);
      return false;
    }
    this.backPressTime = newTime;
    promptAction.showToast({ message: $r('app.string.back_toast'), duration: PRESS_TIME });
    return true;
  }

  changeTabStatus(index: number) {
    AppStorage.setOrCreate('currentTabIndex', index);
    const selectedIndex = index;
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    if (selectedIndex === TabBarType.MINE || this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      WindowUtil.updateStatusBarColor(getContext(this), isSystemDark);
    } else {
      WindowUtil.updateStatusBarColor(getContext(this), isSystemDark || TAB_CONTENT_STATUSES[selectedIndex]);
    }
  }

  handleColorModeChange() {
    if (this.isShown) {
      this.changeTabStatus(this.currentIndex);
    }
  }

  build() {
    NavDestination() {
      SideBarContainer(SideBarContainerType.Embed) {
        CustomSideBar({
          currentIndex: this.currentIndex,
          sideBarChange: (currentIndex: number) => {
            this.changeTabStatus(currentIndex);
            this.currentIndex = currentIndex;
          }
        });
        Stack({ alignContent: Alignment.BottomStart }) {
          this.TabComponent()
          CustomTabBar({
            currentIndex: this.currentIndex, tabBarChange: (currentIndex: number) => {
              this.changeTabStatus(currentIndex);
              this.currentIndex = currentIndex;
            }
          })
            .visibility(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? Visibility.None :
            Visibility.Visible)
        }
      }
      .showSideBar(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL)
      .showControlButton(false)
    }
    .transition(TransitionEffect.OPACITY)
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.onBackPress();
      return true;
    })
    .onShown(() => {
      this.isShown = true;
      this.handleColorModeChange();
      CommonConstants.PROMISE_WAIT(500).then(() => {
        AppStorage.setOrCreate('BlurRenderGroup', false);
      })
    })
    .onHidden(() => {
      AppStorage.setOrCreate('BlurRenderGroup', true);
      this.isShown = false;
    })
    .height('100%')
    .width('100%')
  }
}