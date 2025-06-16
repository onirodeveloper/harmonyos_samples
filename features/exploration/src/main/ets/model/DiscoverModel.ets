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
import { Logger } from '@ohos/common';
import { DiscoverService } from '../service/DiscoverService';
import type { DiscoverData } from './DiscoverData';

const TAG = '[DiscoverModel]';

export class DiscoverModel {
  private service: DiscoverService = new DiscoverService();
  private static instance: DiscoverModel;

  private constructor() {
  }

  public static getInstance(): DiscoverModel {
    if (!DiscoverModel.instance) {
      DiscoverModel.instance = new DiscoverModel();
    }
    return DiscoverModel.instance;
  }

  getDiscoveryPage(): Promise<DiscoverData> {
    return this.service.getDiscoveryPageByPreference()
      .then((data: DiscoverData) => {
        return data;
      })
      .catch((err: string) => {
        Logger.error(TAG,
          `Call getDiscoveryPage data from network failed! try to get data form preference. ${err}`);
        return this.service.getDiscoverPage()
          .then((data: DiscoverData) => {
            this.service.setDiscoveryPageToPreference(data);
            return data;
          });
      });
  }

  preloadDiscoveryData(): Promise<void> {
    return this.service.getDiscoverPage()
      .then((result: DiscoverData) => {
        this.service.setDiscoveryPageToPreference(result);
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `Call preloadDiscoveryData data from network failed. ${err.code}, ${err.message}`);
      });
  }
}