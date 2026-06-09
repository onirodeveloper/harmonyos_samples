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

import type { common, StartOptions, Want } from '@kit.AbilityKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { process } from '@kit.ArkTS';

const TAG = '[ProcessUtil]';

export class ProcessUtil {
  private static operationNotSupportedCode: number = 16000061;
  private static startOptionCheckFailedCode: number = 16000067;

  public static exitApp(): void {
    try {
      const pro = new process.ProcessManager();
      pro.exit(0);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `terminateSelf failed error:${err.code}, ${err.message}.`);
    }
  }

  public static terminateAbility(context: common.UIAbilityContext): void {
    try {
      if (!context) {
        Logger.error(TAG, `terminateAbility failed, cause context is null or undefined.`);
        return;
      }
      context.terminateSelf().then(() => {
        Logger.info(TAG, 'terminateSelf succeed');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `terminateSelf failed. Cause ${err.code}, ${err.message}.`);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `terminateSelf failed error:${err.code}, ${err.message}.`);
    }
  }

  public static moveAbilityToBackground(context: common.UIAbilityContext): void {
    try {
      if (!context) {
        Logger.error(TAG, `moveAbilityToBackground failed, cause context is null or undefined.`);
        return;
      }
      context.moveAbilityToBackground().then(() => {
        Logger.info(TAG, 'moveAbilityToBackground succeed');
      }).catch((err: BusinessError) => {
        if (err.code === ProcessUtil.operationNotSupportedCode) {
          ProcessUtil.hideAbility(context);
        }
        Logger.error(TAG, `moveAbilityToBackground failed, cause ${err.code}, ${err.message}`);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `moveAbilityToBackground failed error: ${err.code}, ${err.message}`);
    }
  }

  public static startAbility(context: common.UIAbilityContext, want: Want, options?: StartOptions): Promise<boolean> {
    try {
      if (!context) {
        Logger.error(TAG, `startAbility failed, cause context is null or undefined.`);
        return Promise.resolve(false);
      }
      return context.startAbility(want, options).then(() => {
        Logger.info(TAG, 'startAbility succeed');
        return true;
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `startAbility failed, cause ${err.code}, ${err.message}`);
        return false;
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `startAbility failed error: ${err.code}, ${err.message}`);
      return Promise.resolve(false);
    }
  }

  private static hideAbility(context: common.UIAbilityContext): void {
    try {
      if (!context) {
        Logger.error(TAG, `hideAbility failed, cause context is null or undefined.`);
        return;
      }
      context.hideAbility().then(() => {
        Logger.info(TAG, 'hideAbility succeed');
      }).catch((err: BusinessError) => {
        if (err.code === ProcessUtil.startOptionCheckFailedCode) {
          ProcessUtil.terminateAbility(context);
        }
        Logger.error(TAG, `hideAbility failed, cause ${err.code}, ${err.message}`);
      })
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `hideAbility failed error: ${err.code}, ${err.message}`);
      return;
    }
  }
}