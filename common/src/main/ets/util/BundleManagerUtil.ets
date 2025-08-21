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

import { bundleManager } from '@kit.AbilityKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { BundleInfoData } from '../model/BundleInfoData';
import { StorageKey } from '../constant/CommonEnums';

const TAG = '[BundleManagerUtil]';

export class BundleManagerUtil {
  public static getBundleInfo(): void {
    try {
      bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
        .then((bundleInfo: bundleManager.BundleInfo) => {
          Logger.debug(TAG, `getBundleInfoForSelf successed. ${bundleInfo}`);
          AppStorage.setOrCreate(StorageKey.BUNDLE_INFO,
            new BundleInfoData(bundleInfo.versionName, bundleInfo.versionCode, bundleInfo.name));
        });
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(TAG, `getBundleInfoForSelf failed: code ${error.code}, message ${error.message}`);
    }
  }
}