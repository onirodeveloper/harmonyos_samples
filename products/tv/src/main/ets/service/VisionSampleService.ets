/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { Logger, TriggerEnums } from '@ohos/common';
import { SingleSampleData } from '@ohos/devpractices';
import { MockRequest as HmosRequest } from '@ohos/common/src/main/ets/storagemanager/MockRequest';

const TAG: string = '[VersionSampleService]';

export class VisionSampleService {
  private static instance: VisionSampleService;
  private hmosRequest: HmosRequest = HmosRequest.getInstance();

  private constructor() {
  }

  public static getInstance(): VisionSampleService {
    if (!VisionSampleService.instance) {
      VisionSampleService.instance = new VisionSampleService();
    }
    return VisionSampleService.instance;
  }

  public getVisionSampleList(): Promise<SingleSampleData[]> {
    Logger.info(TAG, 'getVisionSampleList');
    return this.hmosRequest.request(TriggerEnums.VERSION_SAMPLE_TRIGGER);
  }
}
