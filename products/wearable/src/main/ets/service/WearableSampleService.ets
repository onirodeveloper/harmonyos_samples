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
import { TriggerEnums } from '@ohos/common';
// Wearable device type can only get mock data.
import { MockRequest as HmosRequest } from '@ohos/common/src/main/ets/storagemanager/MockRequest';
import { WearableSampleData } from '../model/WearableSampleData';

export class WearableSampleService {
  public constructor() {
  }

  public getWearableSampleListByMock(): Promise<WearableSampleData[]> {
    return new Promise((resolve: (value: WearableSampleData[]) => void,
      reject: (reason?: Object) => void) => {
      HmosRequest.getInstance().request<WearableSampleData[]>(TriggerEnums.WEARABLE_SAMPLE_TRIGGER)
        .then((result: WearableSampleData[]) => {
          resolve(result);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    })
  }
}