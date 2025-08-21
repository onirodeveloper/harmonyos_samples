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

import { CommonConstants, PageContext } from '@ohos/common';
import { SplashEventTypeEnum, SplashViewModel } from '../viewmodel/SplashViewModel';

const TAG: string = '[SplashPage]';

@Entry
@Component
struct SplashPage {
  private pageContext: PageContext = AppStorage.get('pageContext') as PageContext;
  private appPathInfo: NavPathStack = this.pageContext.navPathStack;
  private viewModel: SplashViewModel = new SplashViewModel();

  aboutToAppear(): void {
    this.viewModel.sendEvent(SplashEventTypeEnum.CHECK_FIRST_START);
    this.getUIContext().animateTo({
      delay: CommonConstants.ANIMATION_DELAY,
      duration: CommonConstants.ANIMATION_DURATION,
    }, () => {
      this.viewModel.sendEvent(SplashEventTypeEnum.JUMP_TO_MAIN);
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