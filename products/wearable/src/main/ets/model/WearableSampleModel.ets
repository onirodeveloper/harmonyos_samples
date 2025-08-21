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

import { WearableSampleService } from '../service/WearableSampleService';
import { WearableSampleData } from './WearableSampleData';

const TAG = '[WearableSampleModel]';

export class WearableSampleModel {
  private static instance: WearableSampleModel;
  private service: WearableSampleService = new WearableSampleService();

  private constructor() {
  }

  public static getInstance(): WearableSampleModel {
   if (!WearableSampleModel.instance) {
     WearableSampleModel.instance = new WearableSampleModel();
   }
   return WearableSampleModel.instance;
  }

  public getWearableSampleList(): Promise<WearableSampleData[]> {
    return this.service.getWearableSampleListByMock()
      .then((data: WearableSampleData[]) => {
        return data;
      })
  }
}