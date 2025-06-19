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
import { Logger, MockRequest, PreferenceManager } from '@ohos/common';
import type { SampleCardData, SampleCategory, SampleData } from '../model/SampleData';
import type { SampleCardDetail, SingleSampleData } from '../model/SampleDetailData';

const TAG: string = '[SampleService]';

export class SampleService {
  public constructor() {
  }

  public getSampleListByMock(): Promise<ResponseData<SampleData>> {
    return new Promise((resolve: (value: ResponseData<SampleData>) => void,
      reject: (reason?: BusinessError) => void) => {
      MockRequest.call<ResponseData<SampleData>>(SampleTrigger.SAMPLE_PAGE)
        .then((result: Object) => {
          resolve(result as ResponseData<SampleData>);
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
      PreferenceManager.getInstance()
        .getValue<Record<string, ResponseData<SampleData>>>(SampleTrigger.SAMPLE_PAGE)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, ResponseData<SampleData>>);
          const ret = resp[`${currentPage}_${pageSize}`];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        });
    });
  }

  public setSamplePageToPreference(data: ResponseData<SampleData>): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_PAGE)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, ResponseData<SampleData>>>(SampleTrigger.SAMPLE_PAGE)
              .then((resp) => {
                resp = (resp as Record<string, ResponseData<SampleData>>);
                resp[`${data.currentPage}_${data.pageSize}`] = data;
                PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_PAGE, resp);
                resolve();
              });
          } else {
            const record: Record<string, ResponseData<SampleData>> = {};
            record[`${data.currentPage}_${data.pageSize}`] = data;
            PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_PAGE, record);
          }
        });
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
      PreferenceManager.getInstance()
        .getValue<Record<string, ResponseData<SampleCardData[]>>>(SampleTrigger.SAMPLE_LIST)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, ResponseData<SampleCardData[]>>);
          const ret = resp[`${categoryType}_${currentPage}_${pageSize}`];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        })
    })
  }

  public setSampleListToPreference(categoryType: number, currentPage: number,
    pageSize: number, data: ResponseData<SampleCardData[]>): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_LIST)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, ResponseData<SampleCardData[]>>>(SampleTrigger.SAMPLE_LIST)
              .then((resp) => {
                resp = (resp as Record<string, ResponseData<SampleCardData[]>>);
                resp[`${categoryType}_${currentPage}_${pageSize}`] = data;
                PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_LIST, resp);
                resolve();
              });
          } else {
            const record: Record<string, ResponseData<SampleCardData[]>> = {};
            record[`${categoryType}_${currentPage}_${pageSize}`] = data;
            PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_LIST, record);
          }
        });
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
      PreferenceManager.getInstance()
        .getValue<Record<string, SingleSampleData[]>>(SampleTrigger.SAMPLE_DETAILS)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, SingleSampleData[]>);
          const ret = resp[`SampleCardDetail_${sampleCardId}`];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        });
    });
  }

  public setSampleDetailsToPreference(data: SampleCardDetail[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_DETAILS)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, SingleSampleData[]>>(SampleTrigger.SAMPLE_DETAILS)
              .then((resp) => {
                const res: Record<string, SingleSampleData[]> = (resp as Record<string, SingleSampleData[]>) || {};
                data.forEach((item: SampleCardDetail) => {
                  res[`SampleCardDetail_${item.id}`] = item.sampleDetail;
                });
                PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, res);
                resolve();
              });
          } else {
            const record: Record<string, SingleSampleData[]> = {};
            data.forEach((item: SampleCardDetail) => {
              record[`SampleCardDetail_${item.id}`] = item.sampleDetail;
            });
            PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, record);
          }
        });
    });
  }

  public setSampleDetailToPreference(sampleCardId: number, data: SingleSampleData[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(SampleTrigger.SAMPLE_DETAILS)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, SingleSampleData[]>>(SampleTrigger.SAMPLE_DETAILS)
              .then((resp) => {
                const res: Record<string, SingleSampleData[]> = (resp as Record<string, SingleSampleData[]>) || {};
                res[`SampleCardDetail_${sampleCardId}`] = data;
                PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, res);
                resolve();
              });
          } else {
            const record: Record<string, SingleSampleData[]> = {};
            record[`SampleCardDetail_${sampleCardId}`] = data;
            PreferenceManager.getInstance().setValue(SampleTrigger.SAMPLE_DETAILS, record);
          }
        });
    });
  }
}

enum SampleTrigger {
  SAMPLE_PAGE = 'sample-page',
  SAMPLE_LIST = 'sample-list',
  SAMPLE_DETAILS = 'sample-details',
  SAMPLE_DETAILS_ALL = 'sample-details-all',
}