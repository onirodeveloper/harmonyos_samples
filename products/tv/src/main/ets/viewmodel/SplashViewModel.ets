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
import { CommonConstants, Logger, PageContext, PageEnum, PreferenceManager, StorageKey } from '@ohos/common';

const TAG: string = '[SplashViewModel]';

export enum SplashEventType {
  CHECK_FIRST_START = 'checkFirstStart',
  JUMP_TO_MAIN = 'jumpToMainPage',
  CLEAR_TIMEOUT = 'clearTimeout',
}

export interface SplashEvent {
  type: SplashEventType;
}

export class SplashViewModel {
  private static instance: SplashViewModel;
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  private pageContext: PageContext = AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT) ?? new PageContext();
  private timeoutId?: number;

  private constructor() {}

  public static getInstance(): SplashViewModel {
    if (!SplashViewModel.instance) {
      SplashViewModel.instance = new SplashViewModel();
    }
    return SplashViewModel.instance;
  }

  public sendEvent(event: SplashEvent): void {
    if (event.type === SplashEventType.JUMP_TO_MAIN) {
      this.jumpToMainPage();
    } else if (event.type === SplashEventType.CHECK_FIRST_START) {
      this.checkIsFirstStart();
    } else if (event.type === SplashEventType.CLEAR_TIMEOUT) {
      this.clearTimeout();
    }
  }

  private jumpToMainPage(): void {
    this.clearTimeout();
    this.pageContext?.replacePage({
      routerName: PageEnum.MAIN_PAGE,
    });
  }

  clearTimeout() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = undefined;
    }
  }

  private checkIsFirstStart(): void {
    const hasValue: boolean = this.preferenceManager.hasValue('isFirstStart');
    if (hasValue) {
      Logger.info(TAG, 'Not first startup.');
      this.jumpToMainPage();
    } else {
      Logger.info(TAG, 'First startup.');
      this.preferenceManager.setValue('isFirstStart', false);
    }
    this.timeoutId = setTimeout(() => {
      this.jumpToMainPage();
    }, CommonConstants.START_DELAY);
  }
}
