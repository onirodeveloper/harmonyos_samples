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

import type { BusinessError } from '@kit.BasicServicesKit';
import { AccountService, BaseVM, BaseVMEvent, Logger } from '@ohos/common';
import { SettingState } from './SettingState';

const TAG: string = '[SettingPageVM]';

export class SettingPageVM extends BaseVM<SettingState> {
  private static instance: SettingPageVM;

  private constructor() {
    super(new SettingState());
  }

  public static getInstance() {
    if (!SettingPageVM.instance) {
      SettingPageVM.instance = new SettingPageVM();
    }
    return SettingPageVM.instance;
  }

  public sendEvent(event: BaseVMEvent | InitEvent): void {
    if (event instanceof LogoutEvent) {
      this.logout();
    } else if (event instanceof InitEvent) {
      this.updateAccountData();
    }
  }

  private logout(): void {
    AccountService.getInstance().logoutDirect()
      .then((isLogout: boolean) => {
        if (isLogout) {
          this.state.isLoggedIn = false;
          this.state.avatarUrl = '';
          this.state.nickName = '';
        }
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `LogoutDirect failed. cause ${error.message}`);
      });
  }

  private updateAccountData(): void {
    const userInfo = AccountService.getInstance().getUserInfo();
    if (userInfo) {
      this.state.avatarUrl = userInfo.avatarUrl;
      this.state.nickName = userInfo.nickname;
      this.state.isLoggedIn = true;
    } else {
      this.state.avatarUrl = '';
      this.state.nickName = '';
      this.state.isLoggedIn = false;
    }
  }
}

export class LogoutEvent implements BaseVMEvent {
  uiContext: UIContext;

  public constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }
}

export class InitEvent {
  public constructor() {
  }
}