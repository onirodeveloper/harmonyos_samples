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

import { Logger } from '@ohos/common';
import { SingleSampleData } from '@ohos/devpractices';
import { VisionSampleService } from '../service/VisionSampleService';

const TAG: string = '[VisionSampleModel]';

export class VisionSampleModel {
  private static instance: VisionSampleModel;
  private versionSampleService: VisionSampleService = VisionSampleService.getInstance();

  private constructor() {
  }

  public static getInstance(): VisionSampleModel {
    if (!VisionSampleModel.instance) {
      VisionSampleModel.instance = new VisionSampleModel();
    }
    return VisionSampleModel.instance;
  }

  public async getVisionSampleList(): Promise<SingleSampleData[]> {
    Logger.info(TAG, 'getVisionSampleList');
    return this.versionSampleService.getVisionSampleList();
  }
}
