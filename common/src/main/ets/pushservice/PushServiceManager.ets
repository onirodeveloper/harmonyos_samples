/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { pushService } from '@kit.PushKit';
import Logger from '../util/Logger';
import { PushService } from './PushService';

const TAG: string = '[PushService]';

export class PushServiceManager {
  private static instance: PushServiceManager;

  private constructor() {
  }

  static getInstance(): PushServiceManager {
    if (!PushServiceManager.instance) {
      PushServiceManager.instance = new PushServiceManager();
    }
    return PushServiceManager.instance;
  }

  public async initPushServiceManager(context: Context): Promise<void> {
    try {
      const enable: boolean | void = await this.requestEnableNotification(context as common.UIAbilityContext);
      if (enable) {
        await this.uploadPushToken();
      }
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Init pushServiceManager error, cause: ${error?.message}, code: ${error?.code}`);
    }
  }

  /**
   * Get the notification enable result, if not enabled, invoke notificationManager's requestEnableNotification.
   *
   * @param context common.UIAbilityContext
   * @returns Promise
   */
  private requestEnableNotification(context: common.UIAbilityContext): Promise<boolean | void> {
    try {
      const enabled: boolean = notificationManager.isNotificationEnabledSync();
      if (!enabled) {
        return notificationManager.requestEnableNotification(context).then(() => {
          Logger.info(TAG, 'RequestEnableNotification success');
          return true;
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `RequestEnableNotification error, cause: ${error?.message}, code: ${error?.code}`);
          return false;
        })
      }
      return Promise.resolve(true);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Is NotificationEnabled error, cause: ${error?.message}, code: ${error?.code}`);
      return Promise.resolve(false);
    }
  }

  /**
   * upload the push token to server.
   *
   * @returns Promise<void>
   */
  private async uploadPushToken(): Promise<void> {
    try {
      const pushToken: string = await pushService.getToken();
      const params: PushTokenParams = {
        pushToken,
      }
      PushService.postPushToken(params);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Get params error, cause: ${error?.message}, code: ${error?.code}`);
    }
  }
}

export interface PushTokenParams {
  pushToken: string,
}