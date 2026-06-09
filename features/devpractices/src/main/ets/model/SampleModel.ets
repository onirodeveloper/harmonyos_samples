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
import { ImageKnifeUtil, Logger, PageData } from '@ohos/common';
import { SampleService } from '../service/SampleService';
import type { SampleCardData, SampleCategory, SampleContent, SampleData } from './SampleData';

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

  public getSamplePage(currentPage: number, pageSize: number): Promise<PageData<SampleData>> {
    return this.service.getSamplePage(currentPage, pageSize)
      .then((data: PageData<SampleData>) => {
        this.service.setSamplePageToPreference(data);
        return data;
      }).catch((err: string) => {
        Logger.error(TAG,
          `getSamplePage data from network failed! try to get data form preference. ${err}`);
        return this.service.getSamplePageByPreference(currentPage, pageSize)
          .then((data: PageData<SampleData>) => {
            return data;
          });
      });
  }

  public getSampleList(categoryId: number, currentPage: number, pageSize: number): Promise<PageData<SampleCardData[]>> {
    return this.service.getSampleList(categoryId, currentPage, pageSize)
      .then((data: PageData<SampleCardData[]>) => {
        data.data?.forEach((sampleCard: SampleCardData) => {
          sampleCard.sampleContents?.forEach((sample: SampleContent) => {
            if (sample.mediaInfoList.length > 0 && sample.mediaInfoList[0].mediaUrl !== undefined) {
              ImageKnifeUtil.preloadImg(sample.mediaInfoList[0].mediaUrl);
            }
          });
        });
        this.service.setSampleListToPreference(categoryId, currentPage, pageSize, data);
        return data;
      })
      .catch((err: string) => {
        Logger.error(TAG,
          `getSamplePage data from network failed! try to get data form preference. ${err}`);
        return this.service.getSampleListByPreference(categoryId, currentPage, pageSize)
          .then((data: PageData<SampleCardData[]>) => {
            return data;
          });
      });
  }

  public preloadSamplePageData(): Promise<void> {
    return this.service.getSamplePage(1, 30)
      .then((result: PageData<SampleData>) => {
        result.data.sampleCategories?.forEach((category: SampleCategory) => {
          category.sampleCards?.forEach((sampleCard: SampleCardData) => {
            sampleCard.sampleContents?.forEach((sample: SampleContent) => {
              if (sample.mediaInfoList[0].mediaUrl !== undefined) {
                ImageKnifeUtil.preloadImg(sample.mediaInfoList[0].mediaUrl);
              }
            });
          });
        });
        this.service.setSamplePageToPreference(result);
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `preloadDiscoveryData data from network failed. ${err.code}, ${err.message}`);
      });
  }
}
