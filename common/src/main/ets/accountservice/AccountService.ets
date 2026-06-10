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

import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import type { BusinessError } from '@kit.BasicServicesKit';
import { commonEventManager, emitter } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constant/CommonConstants';
import { PreferenceManager } from '../storagemanager/PreferenceManager';
import Logger from '../util/Logger';
import { UserAccount } from './model/UserAccount';

const TAG: string = '[AccountService]';
const USER_LOGIN = 'userLogin';
const USER_ACCOUNT = 'userAccount';

export class AccountService {
  private static instance: AccountService;
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  private userAccount: UserAccount = new UserAccount();
  private phoneLogin: boolean = false;
  public userLogin: boolean = false;
  private loginCallbacks: ((userAccount: UserAccount) => void)[] = [];
  private logoutCallbacks: ((userAccount: UserAccount) => void)[] = [];

  private constructor() {
  }

  public static getInstance(): AccountService {
    if (!AccountService.instance) {
      AccountService.instance = new AccountService();
    }
    return AccountService.instance;
  }

  init() {
    this.userLogin = this.preferenceManager.getValue(USER_LOGIN) as boolean ?? this.userLogin;
    this.userAccount = this.preferenceManager.getValue(USER_ACCOUNT) as UserAccount ?? this.userAccount;
    const loginStateRequest: authentication.StateRequest = {
      idType: authentication.IdType.UNION_ID,
      idValue: this.userAccount.unionId,
    };
    new authentication.HuaweiIDProvider().getHuaweiIDState(loginStateRequest)
      .then((result: authentication.StateResult) => {
        if (result.state !== authentication.State.AUTHORIZED) {
          this.userLogin = false;
        }
        this.phoneLogin =
          (result.state === authentication.State.AUTHORIZED || result.state === authentication.State.UNAUTHORIZED);
        this.updatePreference(this.userLogin, this.userAccount);
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `Get HuaweiID state failed, cause code: ${error.code}, message: ${error.message}.`);
      });
    this.subscribeAccountLoginState();
  }

  private subscribeAccountLoginState() {
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [
        commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGIN,
        commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGOUT,
      ],
    };
    let subscriber: commonEventManager.CommonEventSubscriber;
    commonEventManager.createSubscriber(subscribeInfo)
      .then((commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
        subscriber = commonEventSubscriber;
        commonEventManager.subscribe(subscriber,
          (error: BusinessError, data: commonEventManager.CommonEventData) => {
            if (error) {
              Logger.error(TAG,
                `Failed to subscribe phone HauweiID state, code is ${error.code}, message is ${error.message}.`);
            } else {
              if (data.event === commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGIN) {
                this.phoneLogin = true;
              }
              if (data.event === commonEventManager.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGOUT) {
                this.userLogin = false;
                this.phoneLogin = false;
                this.finishLogin();
                emitter.emit(CommonConstants.BIND_LOGOUT_EVENT);
              }
            }
          });
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to create subscriber, code is ${err.code}, message is ${err.message}.`);
      });
  }

  public getUserInfo(): UserAccount | undefined {
    if (this.userLogin === true) {
      return this.userAccount;
    } else {
      return undefined;
    }
  }

  public addAppLogoutListener(logoutCallback: () => void) {
    this.logoutCallbacks.push(logoutCallback);
  }

  public addAppLoginListener(loginCallback: (userAccount: UserAccount) => void) {
    this.loginCallbacks.push(loginCallback);
  }

  public login(uiContext: UIContext): Promise<UserAccount> {
    return new Promise((resolve, reject) => {
      this.getAuthCredential(uiContext).then((authCredential: authentication.AuthorizationWithHuaweiIDCredential) => {
        this.userAccount.avatarUrl = authCredential.avatarUri ?? '';
        this.userAccount.nickname = authCredential.nickName ?? '';
        this.userAccount.unionId = authCredential.unionID ?? '';
        // show sheet and huawei Account to login
        resolve(this.userAccount);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Login with HuaweiID false, error code is ${error.code}, error message is ${error.message}.`);
        reject(error);
      });
    });
  }

  private getAuthCredential(uiContext: UIContext): Promise<authentication.AuthorizationWithHuaweiIDCredential> {
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    authRequest.scopes = ['profile'];
    authRequest.permissions = ['serviceauthcode'];
    authRequest.forceAuthorization = true;
    authRequest.state = util.generateRandomUUID();
    authRequest.idTokenSignAlgorithm = authentication.IdTokenSignAlgorithm.PS256;
    const controller = new authentication.AuthenticationController(uiContext.getHostContext());
    return new Promise((resolve, reject) => {
      controller.executeRequest(authRequest).then((result) => {
        const authorizationWithHuaweiIDResponse = result as authentication.AuthorizationWithHuaweiIDResponse;
        const state = authorizationWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          Logger.error(TAG, `Perform authorization with HuaweiID request error.`);
          reject(new Error('Perform authorization with HuaweiID request error.'));
        }
        const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data;
        if (!authorizationWithHuaweiIDCredential) {
          Logger.error(TAG, `Authorization credential is missing.`);
          reject(new Error(`Authorization credential is missing.`));
          return;
        }
        resolve(authorizationWithHuaweiIDCredential);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Login with HuaweiID false, cause: code: ${error.code}, message: ${error.message}.`);
        reject(error);
      });
    });
  }

  public logout(uiContext: UIContext): Promise<boolean> {
    return new Promise((resolve: (value: boolean) => void,
      reject: (reason?: Object) => void) => {
      resolve(true);
    });
  }

  public logoutDirect(): Promise<boolean> {
    return new Promise((resolve: (value: boolean) => void,
      reject: (reason?: Object) => void) => {
      this.userLogin = false;
      emitter.emit(CommonConstants.BIND_LOGOUT_EVENT);
      this.finishLogin();
      resolve(true);
    });
  }

  public selectHuaweiAccountToLogin() {
    this.userLogin = true;
    this.updatePreference(this.userLogin, this.userAccount);
    emitter.emit(CommonConstants.BIND_MINE_LOGIN_EVENT)
  }


  private finishLogin() {
    this.updatePreference(this.userLogin, this.userAccount);
    if (this.userLogin) {
      this.loginCallbacks.forEach(callback => {
        callback(this.userAccount)
      });
    } else {
      this.logoutCallbacks.forEach(callback => {
        callback(this.userAccount)
      });
    }
  }

  private updatePreference(userLogin: boolean, userAccount?: UserAccount) {
    this.preferenceManager.setValue(USER_LOGIN, userLogin);
    this.preferenceManager.setValue(USER_ACCOUNT, userAccount);
  }
}