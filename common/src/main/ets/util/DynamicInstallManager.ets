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

import type { common, StartOptions } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { moduleInstallManager } from '@kit.StoreKit';
import Logger from './Logger';
import { CommonConstants } from '../constant/CommonConstants';
import { StorageKey } from '../constant/CommonEnums';

const DOWNLOAD_TIMEOUT_LIMIT: number = 1800;
const TAG: string = '[DynamicInstallManager]';

export class DynamicInstallManager {
  private static aVAbilityList: string[] = [
    'KnocksharesampleAbility',
    'VideocastsampleAbility',
    'AudiointeractionsampleAbility',
  ];

  public static getModuleStatus(moduleName: string): moduleInstallManager.InstallStatus {
    try {
      const result: moduleInstallManager.InstalledModule = moduleInstallManager.getInstalledModule(moduleName);
      Logger.info(TAG, `getModuleStatus moduleName: ${result.moduleName}, installStatus: ${result.installStatus}`);
      return result.installStatus;
    } catch {
      Logger.error(TAG, `GetModuleStatus getInstalledModule failed.`);
      return moduleInstallManager.InstallStatus.NOT_INSTALLED;
    }
  }

  public static fetchModule(context: common.UIAbilityContext,
    moduleName: string): Promise<moduleInstallManager.ModuleInstallSessionState> {
    return new Promise((resolve: (value: moduleInstallManager.ModuleInstallSessionState) => void,
      reject: (reason?: object) => void) => {
      try {
        Logger.info(TAG, `fetchModule moduleName: ${moduleName}`);
        const myModuleInstallProvider: moduleInstallManager.ModuleInstallProvider =
          new moduleInstallManager.ModuleInstallProvider();
        const moduleInstallRequest: moduleInstallManager.ModuleInstallRequest =
          myModuleInstallProvider.createModuleInstallRequest(context);
        moduleInstallRequest.addModule(moduleName);
        moduleInstallManager.fetchModules(moduleInstallRequest)
          .then((data: moduleInstallManager.ModuleInstallSessionState) => {
            Logger.debug(TAG, `fetchModule success, result: ${JSON.stringify(data)}`);
            resolve(data);
          });
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `request installing module failed, error: ${err.code} ${err.message}`);
        reject(error);
      }
    });
  }

  public static cancelDownloadTask(taskId?: string): void {
    try {
      const rtnCode: moduleInstallManager.ReturnCode = moduleInstallManager.cancelTask(taskId);
      Logger.info(TAG, `Succeeded in getting result: ${rtnCode}`);
    } catch (error) {
      Logger.error(TAG, `cancelTask error code is ${error.code}, message is ${error.message}`);
    }
  }

  public static subscribeDownloadProgress(): void {
    try {
      moduleInstallManager.on('moduleInstallStatus', (downloadData: moduleInstallManager.ModuleInstallSessionState) => {
        Logger.info(TAG,
          `subscribeDownloadProgress downloadsize: ${downloadData.downloadedSize}, totalsize: ${downloadData.totalSize}`);
        const eventData: emitter.EventData = {
          data: {
            'taskStatus': downloadData.taskStatus,
            'downloadedSize': downloadData.downloadedSize,
            'totalSize': downloadData.totalSize
          }
        };
        emitter.emit(CommonConstants.DYNAMIC_INSTALL_EVENT, eventData);
      }, DOWNLOAD_TIMEOUT_LIMIT);
      Logger.info(TAG, 'subscribe download progress success');
    } catch (error) {
      Logger.error(TAG, `subscribeDownloadProgress failed, error: ${error.code}, ${error.message}`);
    }
  }

  public static unsubscribeDownloadProgress(): void {
    try {
      moduleInstallManager.off('moduleInstallStatus');
      Logger.info(TAG, 'unsubscribe download progress success');
    } catch (error) {
      Logger.error(TAG, `onListening error code is ${error.code}, message is ${error.message}`);
    }
  }

  public static loadModule(context: common.UIAbilityContext, moduleAbility: string): Promise<void> {
    return new Promise((resolve: (value: void) => void, reject: (reason?: BusinessError) => void) => {
      try {
        const isAVAbility: boolean = DynamicInstallManager.aVAbilityList.includes(moduleAbility);
        const isSameAbility: boolean = (moduleAbility === AppStorage.get('AVAbilityModule'));
        const aVAbilityContext: common.UIAbilityContext =
          AppStorage.get<common.UIAbilityContext>('AVAbilityContext') as common.UIAbilityContext;
        if (isAVAbility && !isSameAbility && aVAbilityContext) {
          aVAbilityContext.terminateSelf();
          AppStorage.delete('AVAbilityContext');
        }
        const option: StartOptions = DynamicInstallManager.setStartAbilityProperty();
        context.startAbility({ bundleName: context.abilityInfo.bundleName, abilityName: moduleAbility }, option)
          .then(() => {
            if (isAVAbility) {
              AppStorage.setOrCreate('AVAbilityModule', moduleAbility);
            }
            Logger.info(TAG, `start ${moduleAbility} success}`);
            resolve();
          })
          .catch((error: BusinessError) => {
            Logger.error(TAG,
              `start ${moduleAbility} failed, error code is ${error.code}, message is ${error.message}`);
            reject(error);
          });
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `startAbility failed, error code is ${err.code}, message is ${err.message}`);
      }
    });
  }

  public static setStartAbilityProperty(): StartOptions {
    try {
      const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
      const displayData = display.getDefaultDisplaySync();
      const windowWidth = displayData.availableWidth * CommonConstants.WINDOW_RATIO;
      const windowHeight = displayData.availableHeight * CommonConstants.WINDOW_RATIO;
      const windowLeft = (displayData.availableWidth - windowWidth) / 2.0;
      const windowTop = (displayData.availableHeight - windowHeight) / 2.0;
      const option: StartOptions = {
        minWindowWidth: Math.min(uiContext.px2vp(windowWidth), CommonConstants.MIN_WINDOW_WIDTH),
        minWindowHeight: Math.min(uiContext.px2vp(windowHeight), CommonConstants.MIN_WINDOW_HEIGHT),
        windowLeft: windowLeft,
        windowTop: windowTop,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
      };
      return option;
    } catch {
      Logger.error(TAG, `SetStartAbilityProperty getDefaultDisplaySync failed.`);
      return {};
    }
  }
}