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
import { ResponseData, SampleDistributionUtil } from '@ohos/common';
import { Logger, MockRequest, PreferenceManager } from '@ohos/common';
import type { SampleCardData, SampleCategory, SampleContent, SampleData } from '../model/SampleData';
import type { SampleCardDetail, SingleSampleData } from '../model/SampleDetailData';

const TAG: string = '[SampleService]';

export class SampleService {
  public constructor() {
  }

  public getSampleListByMock(): Promise<ResponseData<SampleData>> {
    return new Promise((resolve: (value: ResponseData<SampleData>) => void,
      reject: (reason?: BusinessError) => void) => {
      MockRequest.call<ResponseData<SampleData>>(SampleTrigger.SAMPLE_PAGE)
        .then((result: ResponseData<SampleData>) => {
          result.data.sampleCategories = this.filterAvailableSamples(result.data.sampleCategories);
          resolve(result);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getSampleDetailsByMock(): Promise<SampleCardDetail[]> {
    return new Promise((resolve: (value: SampleCardDetail[]) => void,
      reject: (reason?: BusinessError) => void) => {
      MockRequest.call<SampleCardDetail[]>(SampleTrigger.SAMPLE_DETAILS_ALL)
        .then((result: SampleCardDetail[]) => {
          resolve(result as SampleCardDetail[]);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getSamplePage(currentPage?: number, pageSize?: number): Promise<ResponseData<SampleData>> {
    Logger.info(TAG, `getComponentList param: currentPage ${currentPage}, pageSize: ${pageSize} `);
    return this.getSampleListByMock();
  }

  public getSamplePageByPreference(currentPage: number, pageSize: number): Promise<ResponseData<SampleData>> {
    return new Promise((resolve: (value: ResponseData<SampleData>) => void,
      reject: (reason?: string) => void) => {
      let response =
        PreferenceManager.getInstance().getValue<Record<string, ResponseData<SampleData>>>(SampleTrigger.SAMPLE_PAGE);
      if (!response) {
        reject('There is no data in the Preference');
      }
      response = (response as Record<string, ResponseData<SampleData>>);
      const ret = response[`${currentPage}_${pageSize}`];
      if (!ret) {
        reject('There is no data in the Preference');
      }
      resolve(ret);
    });
  }

  public setSamplePageToPreference(data: ResponseData<SampleData>): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_PAGE);
      if (hasValue) {
        let resp =
          PreferenceManager.getInstance().getValue<Record<string, ResponseData<SampleData>>>(SampleTrigger.SAMPLE_PAGE);
        resp = (resp as Record<string, ResponseData<SampleData>>) || {};
        resp[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_PAGE, resp);
        resolve();
      } else {
        const record: Record<string, ResponseData<SampleData>> = {};
        record[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_PAGE, record);
      }
    });
  }

  public getSampleList(categoryType: number, currentPage: number,
    pageSize: number): Promise<ResponseData<SampleCardData[]>> {
    return new Promise((resolve: (value: ResponseData<SampleCardData[]>) => void,
      reject: (reason?: Object) => void) => {
      this.getSampleListByMock().then((result: ResponseData<SampleData>) => {
        const sampleCategoryList = result.data.sampleCategories;
        const categoryData =
          sampleCategoryList.find((category: SampleCategory) => category.categoryType === categoryType);
        const response: ResponseData<SampleCardData[]> = {
          currentPage,
          pageSize,
          totalSize: 0,
          data: [],
        };
        if (categoryData) {
          response.totalSize = categoryData.sampleCards.length;
          response.data = categoryData.sampleCards;
        }
        resolve(response);
      }).catch(() => {
        reject();
      });
    });
  }

  public getSampleListByPreference(categoryType: number, currentPage: number,
    pageSize: number): Promise<ResponseData<SampleCardData[]>> {
    return new Promise((resolve: (value: ResponseData<SampleCardData[]>) => void,
      reject: (reason?: string) => void) => {
      let resp = PreferenceManager.getInstance()
        .getValue<Record<string, ResponseData<SampleCardData[]>>>(SampleTrigger.SAMPLE_LIST);
      if (!resp) {
        reject('There is no data in the Preference');
      }
      resp = (resp as Record<string, ResponseData<SampleCardData[]>>);
      const ret = resp[`${categoryType}_${currentPage}_${pageSize}`];
      if (!ret) {
        reject('There is no data in the Preference');
      }
      resolve(ret);
    });
  }

  public setSampleListToPreference(categoryType: number, currentPage: number,
    pageSize: number, data: ResponseData<SampleCardData[]>): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_LIST);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<Record<string, ResponseData<SampleCardData[]>>>(SampleTrigger.SAMPLE_LIST);
        resp = (resp as Record<string, ResponseData<SampleCardData[]>>) || {};
        resp[`${categoryType}_${currentPage}_${pageSize}`] = data;
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_LIST, resp);
        resolve();
      } else {
        const record: Record<string, ResponseData<SampleCardData[]>> = {};
        record[`${categoryType}_${currentPage}_${pageSize}`] = data;
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_LIST, record);
      }
    });
  }

  public getSampleDetails(sampleCardId: number): Promise<SingleSampleData[]> {
    return new Promise((resolve: (value: SingleSampleData[]) => void, reject: (reason?: Object) => void) => {
      this.getSampleDetailsByMock().then((result: SampleCardDetail[]) => {
        const cardDetail = result.find((item: SampleCardDetail) => item.id === sampleCardId);
        if (cardDetail) {
          resolve(cardDetail.sampleDetail);
        } else {
          reject(`Cann't find this Sample Card. id: ${sampleCardId}`);
        }
      }).catch((error: BusinessError) => {
        reject(error);
      });
    });
  }

  public getSampleDetailsByPreference(sampleCardId: number): Promise<SingleSampleData[]> {
    return new Promise((resolve: (value: SingleSampleData[]) => void,
      reject: (reason?: string) => void) => {
      const detailsKey = SampleTrigger.SAMPLE_DETAILS;
      const response: Record<string, SingleSampleData[]> = PreferenceManager.getInstance()
        .getValue<Record<string, SingleSampleData[]>>(detailsKey) as Record<string, SingleSampleData[]>;
      if (!response) {
        reject('There is no data in the Preference');
      }
      const ret = response[`SampleCardDetail_${sampleCardId}`];
      if (!ret) {
        reject('There is no data in the Preference');
      }
      resolve(ret);
    });
  }

  public setSampleDetailsToPreference(data: SampleCardDetail[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_DETAILS);
      if (hasValue) {
        const response =
          PreferenceManager.getInstance().getValue<Record<string, SingleSampleData[]>>(SampleTrigger.SAMPLE_DETAILS)
        const res: Record<string, SingleSampleData[]> = (response as Record<string, SingleSampleData[]>) || {};
        data.forEach((item: SampleCardDetail) => {
          res[`SampleCardDetail_${item.id}`] = item.sampleDetail;
        });
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, res);
        resolve();
      } else {
        const record: Record<string, SingleSampleData[]> = {};
        data.forEach((item: SampleCardDetail) => {
          record[`SampleCardDetail_${item.id}`] = item.sampleDetail;
        });
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, record);
      }
    });
  }

  public setSampleDetailToPreference(sampleCardId: number, data: SingleSampleData[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_DETAILS);
      if (hasValue) {
        const response =
          PreferenceManager.getInstance().getValue<Record<string, SingleSampleData[]>>(SampleTrigger.SAMPLE_DETAILS);
        const res: Record<string, SingleSampleData[]> = (response as Record<string, SingleSampleData[]>) || {};
        res[`SampleCardDetail_${sampleCardId}`] = data;
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, res);
        resolve();
      } else {
        const record: Record<string, SingleSampleData[]> = {};
        record[`SampleCardDetail_${sampleCardId}`] = data;
        PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, record);
      }
    });
  }

  private filterAvailableSamples(allCategories: SampleCategory[]): SampleCategory[] {
    let sampleCategories: SampleCategory[] = [];
    allCategories.forEach((sampleCategory: SampleCategory) => {
      let sampleCards: SampleCardData[] = [];
      sampleCategory.sampleCards.forEach((sampleCard: SampleCardData) => {
        if (sampleCard.sampleContents.length !== 1 ||
        SampleDistributionUtil.checkSampleSupport(sampleCard.sampleContents[0].requiredApiVersion,
          sampleCard.sampleContents[0].supportDeviceList)) {
          let supportSamples: SampleContent[] = [];
          sampleCard.sampleContents.forEach((sampleContent: SampleContent) => {
            if (SampleDistributionUtil.checkSampleSupport(sampleContent.requiredApiVersion,
              sampleContent.supportDeviceList)) {
              supportSamples.push(sampleContent);
            }
          });
          sampleCard.sampleContents = supportSamples;
          sampleCards.push(sampleCard);
        }
      });
      sampleCategory.sampleCards = sampleCards;
      sampleCategories.push(sampleCategory);
    });
    return sampleCategories;
  }
}

enum SampleTrigger {
  SAMPLE_PAGE = 'sample-page',
  SAMPLE_LIST = 'sample-list',
  SAMPLE_DETAILS = 'sample-details',
  SAMPLE_DETAILS_ALL = 'sample-details-all',
}