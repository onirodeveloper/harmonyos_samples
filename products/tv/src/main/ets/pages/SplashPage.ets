/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';
import { SplashViewModel, SplashEventType } from '../viewmodel/SplashViewModel';
import { CommonConstants, StorageKey, Logger, PageContext } from '@ohos/common';

const TAG: string = '[SplashPage]';

@Preview
@Entry
@Component
struct SplashPage {
  @StorageLink(StorageKey.HOME_PAGE_CONTEXT) pageContext: PageContext = new PageContext();
  private appPathStack: NavPathStack = this.pageContext.navPathStack;
  private viewModel: SplashViewModel = SplashViewModel.getInstance();

  aboutToAppear(): void {
    Logger.info(TAG, 'SplashPage aboutToAppear');
    this.viewModel.sendEvent({ type: SplashEventType.CHECK_FIRST_START });
  }

  aboutToDisappear(): void {
    Logger.info(TAG, 'SplashPage aboutToDisappear');
    this.viewModel.sendEvent({ type: SplashEventType.CLEAR_TIMEOUT });
  }

  build() {
    HdsNavigation(this.appPathStack) {
      Column() {
        Image($rawfile('image/splash_screen.png'))
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .syncLoad(true)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.start_window_background'))
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}
