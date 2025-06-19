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
import { CommonConstants, Logger, PageContext, WindowUtil, } from '@ohos/common';
import { SplashEventTypeEnum, SplashViewModel } from '../viewmodel/SplashViewModel';

const TAG: string = '[SplashPage]';

@Entry
@Component
struct SplashPage {
  private pageContext: PageContext = AppStorage.get('pageContext') as PageContext;
  private appPathInfo: NavPathStack = this.pageContext.navPathStack;
  private viewModel: SplashViewModel = new SplashViewModel();

  onPageHide() {
    Logger.info(TAG, 'onPageHide');
    WindowUtil.updateStatusBarColor(getContext(this),
      AppStorage.get('systemColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  aboutToAppear(): void {
    WindowUtil.updateStatusBarColor(getContext(this), true);
    this.viewModel.sendEvent(SplashEventTypeEnum.CHECK_FIRST_START);
    animateTo({
      delay: CommonConstants.ANIMATION_DELAY,
      duration: CommonConstants.ANIMATION_DURATION,
      onFinish: () => {
        this.viewModel.sendEvent(SplashEventTypeEnum.JUMP_TO_MAIN);
      }
    }, () => {
      this.viewModel.sendEvent(SplashEventTypeEnum.PRELOAD_RESOURCES);
    })
  }

  build() {
    Navigation(this.appPathInfo) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.start_window_background'))
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
  }
}