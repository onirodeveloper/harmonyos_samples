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

import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import type { PageData } from '@ohos/common';
import { HmosRequest, Logger, PreferenceManager, TriggerEnums } from '@ohos/common';
import { BaseDetailParam, BaseListParam } from '@ohos/commonbusiness';
import type { SampleCardData, SampleData } from '../model/SampleData';
import type { SampleCardDetail, SingleSampleData } from '../model/SampleDetailData';

const TAG: string = '[SampleService]';

export class SampleService {
  public constructor() {
  }

  public getSamplePage(currentPage: number, pageSize: number): Promise<PageData<SampleData>> {
    Logger.info(TAG, `getComponentList param: currentPage ${currentPage}, pageSize: ${pageSize} `);
    return new Promise((resolve: (value: PageData<SampleData>) => void,
      reject: (reason?: BusinessError) => void) => {
      const param: SamplePageParam = {
        currentPage: currentPage,
        pageSize: pageSize,
        supportDevice: deviceInfo.deviceType,
        apiVersion: deviceInfo.sdkApiVersion,
      };
      HmosRequest.getInstance().request<PageData<SampleData>>(TriggerEnums.SAMPLE_PAGE, param)
        .then((result: PageData<SampleData>) => {
          resolve(result);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getSamplePage failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  public getSamplePageByPreference(currentPage: number, pageSize: number): Promise<PageData<SampleData>> {
    return new Promise((resolve: (value: PageData<SampleData>) => void,
      reject: (reason?: string) => void) => {
      let response =
        PreferenceManager.getInstance().getValue<Record<string, PageData<SampleData>>>(TriggerEnums.SAMPLE_PAGE);
      if (!response) {
        reject('There is no data in the Preference');
        return;
      }
      response = (response as Record<string, PageData<SampleData>>);
      const ret = response[`${currentPage}_${pageSize}`];
      if (!ret) {
        reject('There is no data in the Preference');
        return;
      }
      resolve(ret);
    });
  }

  public setSamplePageToPreference(data: PageData<SampleData>): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(TriggerEnums.SAMPLE_PAGE);
      if (hasValue) {
        let resp =
          PreferenceManager.getInstance().getValue<Record<string, PageData<SampleData>>>(TriggerEnums.SAMPLE_PAGE);
        resp = (resp as Record<string, PageData<SampleData>>) || {};
        resp[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_PAGE, resp);
      } else {
        const record: Record<string, PageData<SampleData>> = {};
        record[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_PAGE, record);
      }
      resolve();
    });
  }

  public getSampleList(categoryId: number, currentPage: number,
    pageSize: number): Promise<PageData<SampleCardData[]>> {
    return new Promise((resolve: (value: PageData<SampleCardData[]>) => void, reject: (reason?: Object) => void) => {
      const param: SampleListParam = {
        categoryId,
        singleId: categoryId,
        currentPage: currentPage,
        pageSize: pageSize,
        supportDevice: deviceInfo.deviceType,
        apiVersion: deviceInfo.sdkApiVersion,
      };
      HmosRequest.getInstance().request<PageData<SampleCardData[]>>(TriggerEnums.SAMPLE_LIST, param)
        .then((result: PageData<SampleCardData[]>) => {
          resolve(result);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getSampleList failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  public getSampleListByPreference(categoryId: number, currentPage: number,
    pageSize: number): Promise<PageData<SampleCardData[]>> {
    return new Promise((resolve: (value: PageData<SampleCardData[]>) => void,
      reject: (reason?: string) => void) => {
      let resp = PreferenceManager.getInstance()
        .getValue<Record<string, PageData<SampleCardData[]>>>(TriggerEnums.SAMPLE_LIST);
      if (!resp) {
        reject('There is no data in the Preference');
        return;
      }
      resp = (resp as Record<string, PageData<SampleCardData[]>>);
      const ret = resp[`${categoryId}_${currentPage}_${pageSize}`];
      if (!ret || ret.data?.length === 0) {
        reject('There is no data in the Preference');
        return;
      }
      resolve(ret);
    });
  }

  public setSampleListToPreference(categoryId: number, currentPage: number,
    pageSize: number, data: PageData<SampleCardData[]>): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(TriggerEnums.SAMPLE_LIST);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<Record<string, PageData<SampleCardData[]>>>(TriggerEnums.SAMPLE_LIST);
        resp = (resp as Record<string, PageData<SampleCardData[]>>) || {};
        resp[`${categoryId}_${currentPage}_${pageSize}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_LIST, resp);
      } else {
        const record: Record<string, PageData<SampleCardData[]>> = {};
        record[`${categoryId}_${currentPage}_${pageSize}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_LIST, record);
      }
      resolve();
    });
  }

  public getSampleDetails(sampleId: number, cardId: number, isUnion: boolean): Promise<SingleSampleData[]> {
    return new Promise((resolve: (value: SingleSampleData[]) => void, reject: (reason?: Object) => void) => {
      const params: SampleDetailParam = {
        isUnion,
        singleId: cardId,
        supportDevice: deviceInfo.deviceType,
        apiVersion: deviceInfo.sdkApiVersion,
      }
      if (cardId > 0) {
        params.cardId = cardId;
      } else {
        params.id = sampleId;
      }
      HmosRequest.getInstance().request<SingleSampleData[]>(TriggerEnums.SAMPLE_DETAILS, params)
        .then((result: SingleSampleData[]) => {
          resolve(result as SingleSampleData[]);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getSampleDetails failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  public getSampleDetailsByPreference(sampleCardId: number): Promise<SingleSampleData[]> {
    return new Promise((resolve: (value: SingleSampleData[]) => void,
      reject: (reason?: string) => void) => {
      const detailsKey = TriggerEnums.SAMPLE_DETAILS;
      const response: Record<string, SingleSampleData[]> = PreferenceManager.getInstance()
        .getValue<Record<string, SingleSampleData[]>>(detailsKey) as Record<string, SingleSampleData[]>;
      if (!response) {
        reject('There is no data in the Preference');
        return;
      }
      const ret = response[`SampleCardDetail_${sampleCardId}`];
      if (!ret) {
        reject('There is no data in the Preference');
        return;
      }
      resolve(ret);
    });
  }

  public setSampleDetailsToPreference(data: SampleCardDetail[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(TriggerEnums.SAMPLE_DETAILS);
      if (hasValue) {
        const response =
          PreferenceManager.getInstance().getValue<Record<string, SingleSampleData[]>>(TriggerEnums.SAMPLE_DETAILS)
        const res: Record<string, SingleSampleData[]> = (response as Record<string, SingleSampleData[]>) || {};
        data.forEach((item: SampleCardDetail) => {
          res[`SampleCardDetail_${item.id}`] = item.sampleDetail;
        });
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_DETAILS, res);
      } else {
        const record: Record<string, SingleSampleData[]> = {};
        data.forEach((item: SampleCardDetail) => {
          record[`SampleCardDetail_${item.id}`] = item.sampleDetail;
        });
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_DETAILS, record);
      }
      resolve();
    });
  }

  public setSampleDetailToPreference(sampleCardId: number, data: SingleSampleData[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(TriggerEnums.SAMPLE_DETAILS);
      if (hasValue) {
        const response =
          PreferenceManager.getInstance().getValue<Record<string, SingleSampleData[]>>(TriggerEnums.SAMPLE_DETAILS);
        const res: Record<string, SingleSampleData[]> = (response as Record<string, SingleSampleData[]>) || {};
        res[`SampleCardDetail_${sampleCardId}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_DETAILS, res);
      } else {
        const record: Record<string, SingleSampleData[]> = {};
        record[`SampleCardDetail_${sampleCardId}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.SAMPLE_DETAILS, record);
      }
      resolve();
    });
  }
}

interface SamplePageParam extends BaseListParam, BaseSampleParam {}

interface SampleListParam extends BaseListParam, BaseDetailParam, BaseSampleParam {
  categoryId: number,
}

interface SampleDetailParam extends BaseDetailParam, BaseSampleParam {
  cardId?: number;
  isUnion?: boolean;
  id?: number;
}

interface BaseSampleParam {
  supportDevice: string;
  apiVersion: number;
}
