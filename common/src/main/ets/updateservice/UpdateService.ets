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

import { updateManager } from '@kit.StoreKit';
import type { common } from '@kit.AbilityKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../util/Logger';
import { StorageKey } from '../constant/CommonEnums';

const TAG: string = '[UpdateService]';

export class UpdateService {
  private static instance: UpdateService;

  private constructor() {
  }

  public static getInstance(): UpdateService {
    if (!UpdateService.instance) {
      UpdateService.instance = new UpdateService();
      return UpdateService.instance;
    }
    return UpdateService.instance;
  }

  public checkUpdate(): Promise<boolean> {
    const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    return new Promise((resolve: Function, reject: Function) => {
      try {

        updateManager.checkAppUpdate(context)
          .then((checkResult: updateManager.CheckUpdateResult) => {
            Logger.info(TAG, `Succeeded in checking Result updateAvailable:` + checkResult.updateAvailable);
            if (checkResult.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
              resolve(true);
            } else {
              resolve(false);
            }
          })
          .catch((error: BusinessError) => {
            Logger.error(TAG, `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
            reject(false);
          });
      } catch (error) {
        Logger.error(TAG, `checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
        reject(false);
      }
    })
  }

  public updateVersion(): Promise<boolean> {
    const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    return new Promise((resolve: Function, reject: Function) => {
      try {
        updateManager.showUpdateDialog(context)
          .then((resultCode: updateManager.ShowUpdateResultCode) => {
            Logger.info(TAG, `Succeeded in showing UpdateDialog resultCode:` + resultCode);
            resolve(true);
          })
          .catch((error: BusinessError) => {
            Logger.error(TAG, `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
            reject(false);
          });
      } catch (error) {
        Logger.error(TAG, `showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
        reject(false);
      }
    });
  }
}