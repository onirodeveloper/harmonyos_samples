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
import { HdsNavDestination, HdsSideBar, } from '@kit.UIDesignKit';
import { HomeView } from '@ohos/abilitycommon';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  ProcessUtil,
  StorageKey,
  Toast,
  ColumnEnum,
} from '@ohos/common';
import { CustomSideBar } from '../component/CustomSideBar';

const PRESS_TIME: number = 1500;
const TAG: string = '[MainPage]';
const SCROLL_PADDING_LG: number = 32;
const BREAKPOINTS: string[] = ['xs', 'sm', 'md', 'lg', 'xl'];

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component({ freezeWhenInactive: true })
struct MainPage {
  @StorageLink(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State currentIndex: number = 0;
  private backPressTime: number = 0;
  @State isShown: boolean = false;

  onPageShow(): void {
    this.isShown = true;
    CommonConstants.PROMISE_WAIT(500).then(() => {
      AppStorage.setOrCreate(StorageKey.BLUE_RENDER_GROUP, false);
    });
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

  @Builder
  CustomSideBarBuilder() {
    CustomSideBar({
      currentIndex: this.currentIndex,
      sideBarChange: (currentIndex: number) => {
        this.currentIndex = currentIndex;
      }
    })
  }

  @Builder
  contentPanelBuilder() {
    GridRow({
      columns: { sm: ColumnEnum.SM, md: ColumnEnum.MD, lg: ColumnEnum.LG },
      direction: GridRowDirection.Row,
      breakpoints: { reference: BreakpointsReference.ComponentSize }
    }) {
      GridCol({ span: { sm: ColumnEnum.SM, md: ColumnEnum.MD, lg: ColumnEnum.LG } }) {
        HomeView({ showTabBar: false, currentIndex: this.currentIndex, isShown: this.isShown })
      }
      .margin({
        left: -SCROLL_PADDING_LG,
        right: -SCROLL_PADDING_LG,
      })
    }
    .padding({
      left: SCROLL_PADDING_LG,
      right: SCROLL_PADDING_LG,
    })
    .clip(false)
    .onBreakpointChange((breakpoints: string) => {
      this.globalInfoModel.widthBreakpoint =
        BREAKPOINTS.includes(breakpoints) ? BREAKPOINTS.indexOf(breakpoints) : WidthBreakpoint.WIDTH_XL;
    })
  }

  build() {
    HdsNavDestination() {
      HdsSideBar({
        isShowSideBar: true,
        autoHide: false,
        sideBarContainerType: SideBarContainerType.Embed,
        sideBarWidth: CommonConstants.SIDE_BAR_WIDTH,
        sideBarPanelBuilder: () => {
          this.CustomSideBarBuilder()
        },
        contentPanelBuilder: () => {
          this.contentPanelBuilder()
        },
      })
    }
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
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