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

import type { SingleSampleData } from '../model/SampleDetailData';
import { SampleService } from '../service/SampleService';

export class SampleDetailModel {
  private service: SampleService = new SampleService();
  private static instance: SampleDetailModel;

  private constructor() {
  }

  public static getInstance(): SampleDetailModel {
    if (!SampleDetailModel.instance) {
      SampleDetailModel.instance = new SampleDetailModel();
    }
    return SampleDetailModel.instance;
  }

  public getSampleCardDetails(sampleCardId: number): Promise<SingleSampleData[]> {
    return this.service.getSampleDetailsByPreference(sampleCardId)
      .then((data: SingleSampleData[]) => {
        return data;
      })
      .catch(() => {
        return this.service.getSampleDetails(sampleCardId)
          .then((data: SingleSampleData[]) => {
            this.service.setSampleDetailToPreference(sampleCardId, data);
            return data;
          });
      });
  }
}