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
import { AllContentData } from '../model/AllContentData';
import { MineTrigger, NewContentData } from '../model/NewContentData';

const TAG = '[MineService]';

export class MineService {
  private static readonly NEW_COMPONENT_DATA = 'NEW_COMPONENT_DATA';
  private static readonly NEW_SAMPLE_DATA = 'NEW_SAMPLE_DATA';
  private static readonly NEW_ARTICLE_DATA = 'NEW_ARTICLE_DATA';
  private static readonly ALL_CONTENT = 'ALL_CONTENT';

  constructor() {
  }

  public getNewContentByMock(type: MineTrigger): Promise<ResponseData<NewContentData[]>> {
    return new Promise((resolve: (value: ResponseData<NewContentData[]>) => void,
      reject: (reason?: Object) => void) => {
      MockRequest.call<ResponseData<NewContentData[]>>(type)
        .then((result: Object) => {
          resolve(result as ResponseData<NewContentData[]>);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getNewContent(type: MineTrigger, currentPage?: number,
    pageSize?: number): Promise<ResponseData<NewContentData[]>> {
    Logger.info(TAG, `get new component content param: currentPage ${currentPage}, pageSize: ${pageSize} `);
    return this.getNewContentByMock(type);
  }

  public getNewContentByPreference(type: MineTrigger, currentPage: number,
    pageSize: number): Promise<ResponseData<NewContentData[]>> {
    return new Promise((resolve: (value: ResponseData<NewContentData[]>) => void,
      reject: (reason?: string) => void) => {
      const key: string = this.getMineServiceKey(type);
      let resp = PreferenceManager.getInstance()
        .getValue<Record<string, ResponseData<NewContentData[]>>>(key);
      if (!resp) {
        reject('There is no data in the Preference');
      }
      resp = (resp as Record<string, ResponseData<NewContentData[]>>);
      const ret = resp[`${currentPage}_${pageSize}`];
      if (!ret) {
        reject('There is no data in the Preference');
      }
      resolve(ret);
    });
  }

  public setNewContentToPreference(type: MineTrigger, data: ResponseData<NewContentData[]>): Promise<void> {
    return new Promise((resolve: () => void) => {
      const key: string = this.getMineServiceKey(type);
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(key);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<Record<string, ResponseData<NewContentData[]>>>(key);
        resp = (resp as Record<string, ResponseData<NewContentData[]>>);
        resp[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(key, resp);
        resolve();
      } else {
        const record: Record<string, ResponseData<NewContentData[]>> = {};
        record[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(key, record);
      }
    });
  }

  public getNewContentNumByMock(type: MineTrigger): Promise<AllContentData> {
    return new Promise((resolve: (value: AllContentData) => void,
      reject: (reason?: Object) => void) => {
      MockRequest.call<AllContentData>(type)
        .then((result: Object) => {
          resolve(result as AllContentData);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getNewContentNumByPreference(type: MineTrigger): Promise<AllContentData> {
    return new Promise((resolve: (value: AllContentData) => void,
      reject: (reason?: string) => void) => {
      const key: string = this.getMineServiceKey(type);
      let resp = PreferenceManager.getInstance()
        .getValue<AllContentData>(key);
      if (!resp) {
        reject('There is no data in the Preference');
      }
      resp = (resp as AllContentData);
      if (!resp) {
        reject('There is no data in the Preference');
      }
      resolve(resp);
    });
  }

  public setNewContentNumToPreference(type: MineTrigger, data: AllContentData): Promise<void> {
    return new Promise((resolve: () => void) => {
      const key: string = this.getMineServiceKey(type);
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(key);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<AllContentData>(key);
        resp = (resp as AllContentData);
        PreferenceManager.getInstance().setValue(key, resp);
        resolve();
      } else {
        PreferenceManager.getInstance().setValue(key, data);
      }
    });
  }

  private getMineServiceKey(type: MineTrigger): string {
    let key: string = '';
    switch (type) {
      case MineTrigger.NEW_COMPONENT:
        key = MineService.NEW_COMPONENT_DATA;
        return key;
      case MineTrigger.NEW_SAMPLE:
        key = MineService.NEW_SAMPLE_DATA;
        return key;
      case MineTrigger.NEW_ARTICLE:
        key = MineService.NEW_ARTICLE_DATA;
        return key;
      case MineTrigger.ALL_CONTENT:
        key = MineService.ALL_CONTENT;
        return key;
      default:
        key = MineService.NEW_COMPONENT_DATA;
        return key;
    }
  }
}