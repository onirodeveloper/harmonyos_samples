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

import type { BusinessError } from '@kit.BasicServicesKit';
import { HmosRequest, Logger, PreferenceManager, TriggerEnums } from '@ohos/common';
import type { DiscoverData } from '../model/DiscoverData';

const TAG: string = '[DiscoverService]';

export class DiscoverService {
  constructor() {
  }

  getDiscoverPage(): Promise<DiscoverData> {
    return new Promise((resolve: (value: DiscoverData) => void,
      reject: (reason?: Object) => void) => {
      HmosRequest.getInstance().request<DiscoverData>(TriggerEnums.DISCOVER_PAGE)
        .then((result: Object) => {
          resolve(result as DiscoverData);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getDiscoverPage failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  getDiscoveryPageByPreference(): Promise<DiscoverData> {
    return new Promise((resolve: (value: DiscoverData) => void,
      reject: (reason?: string) => void) => {
      const result: Record<string, DiscoverData> = PreferenceManager.getInstance()
        .getValue<Record<string, DiscoverData>>(TriggerEnums.DISCOVER_PAGE) as Record<string, DiscoverData>;
      if (!result) {
        reject('There is no data in the Preference');
        return;
      }
      const ret = result[TriggerEnums.DISCOVER_PAGE];
      if (!ret) {
        reject('There is no data in the Preference');
        return;
      }
      resolve(ret);
    });
  }

  setDiscoveryPageToPreference(data: DiscoverData): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(TriggerEnums.DISCOVER_PAGE);
      if (hasValue) {
        const result: Record<string, DiscoverData> = PreferenceManager.getInstance()
          .getValue<Record<string, DiscoverData>>(TriggerEnums.DISCOVER_PAGE) as Record<string, DiscoverData> || {};
        result[TriggerEnums.DISCOVER_PAGE] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.DISCOVER_PAGE, result);
      } else {
        const record: Record<string, DiscoverData> = {};
        record[TriggerEnums.DISCOVER_PAGE] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.DISCOVER_PAGE, record);
      }
      resolve();
    });
  }
}