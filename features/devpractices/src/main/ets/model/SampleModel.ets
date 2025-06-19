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
import type { ResponseData } from '@ohos/common';
import { Logger } from '@ohos/common';
import { SampleService } from '../service/SampleService';
import type { SampleCardData, SampleData } from './SampleData';
import type { SampleCardDetail } from './SampleDetailData';

const TAG = '[SampleModel]';

export class SampleModel {
  private service: SampleService = new SampleService();
  private static instance: SampleModel;

  private constructor() {
  }

  public static getInstance(): SampleModel {
    if (!SampleModel.instance) {
      SampleModel.instance = new SampleModel();
    }
    return SampleModel.instance;
  }

  public getSamplePage(currentPage: number, pageSize: number): Promise<ResponseData<SampleData>> {
    return this.service.getSamplePageByPreference(currentPage, pageSize)
      .then((data: ResponseData<SampleData>) => {
        return data;
      }).catch((err: string) => {
        Logger.error(TAG,
          `getSamplePage data from network failed! try to get data form preference. ${err}`);
        return this.service.getSamplePage(currentPage, pageSize)
          .then((data: ResponseData<SampleData>) => {
            this.service.setSamplePageToPreference(data);
            return data;
          });
      });
  }

  public getSampleList(categoryType: number, currentPage: number,
    pageSize: number): Promise<ResponseData<SampleCardData[]>> {
    return this.service.getSampleListByPreference(categoryType, currentPage, pageSize)
      .then((data: ResponseData<SampleCardData[]>) => {
        return data;
      }).catch((err: string) => {
        Logger.error(TAG,
          `getSamplePage data from network failed! try to get data form preference. ${err}`);
        return this.service.getSampleList(categoryType, currentPage, pageSize)
          .then((data: ResponseData<SampleCardData[]>) => {
            this.service.setSampleListToPreference(categoryType, currentPage, pageSize, data);
            return data;
          });
      });
  }

  public preloadSamplePageData(): Promise<void> {
    this.service.getSampleDetailsByMock().then((sampleDetailList: SampleCardDetail[]) => {
      this.service.setSampleDetailsToPreference(sampleDetailList);
    });
    return this.service.getSamplePage()
      .then((result: ResponseData<SampleData>) => {
        this.service.setSamplePageToPreference(result);
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `preloadDiscoveryData data from network failed. ${err.code}, ${err.message}`);
      });
  }
}