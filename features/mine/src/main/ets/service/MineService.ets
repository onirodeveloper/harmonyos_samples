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
import { HmosRequest, PreferenceManager, TriggerEnums } from '@ohos/common';
import { BaseDetailParam, CardTypeEnum } from '@ohos/commonbusiness';
import { NewContentData } from '../model/NewContentData';

export class MineService {
  constructor() {
  }

  public getNewContent(cardType: CardTypeEnum): Promise<NewContentData[]> {
    return new Promise((resolve: (value: NewContentData[]) => void,
      reject: (reason?: Object) => void) => {
      const param: NewContentParam = {
        type: cardType,
        singleId: cardType,
      } as NewContentParam;
      if (cardType === CardTypeEnum.SAMPLE) {
        param.supportDevice = deviceInfo.deviceType;
        param.apiVersion = deviceInfo.sdkApiVersion;
      }
      HmosRequest.getInstance()
        .request<NewContentData[]>(TriggerEnums.NEW_CONTENTS, param)
        .then((result: Object) => {
          resolve(result as NewContentData[]);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getNewContentByPreference(type: CardTypeEnum): Promise<NewContentData[]> {
    return new Promise((resolve: (value: NewContentData[]) => void,
      reject: (reason?: string) => void) => {
      const response: Record<string, NewContentData[]> = PreferenceManager.getInstance()
        .getValue<Record<string, NewContentData[]>>(TriggerEnums.NEW_CONTENTS) as Record<string, NewContentData[]>;
      if (!response) {
        reject('There is no data in the Preference');
        return;
      }
      const ret = response[`${TriggerEnums.NEW_CONTENTS}_${type}`];
      if (!ret || ret.length === 0) {
        reject('There is no data in the Preference');
        return;
      }
      resolve(ret);
    });
  }

  public setNewContentToPreference(type: CardTypeEnum, data: NewContentData[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(TriggerEnums.NEW_CONTENTS);
      if (hasValue) {
        const resp = PreferenceManager.getInstance()
          .getValue<Record<string, NewContentData[]>>(TriggerEnums.NEW_CONTENTS);
        const res: Record<string, NewContentData[]> = (resp as Record<string, NewContentData[]>) || {};
        res[`${TriggerEnums.NEW_CONTENTS}_${type}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.NEW_CONTENTS, res);
      } else {
        const record: Record<string, NewContentData[]> = {};
        record[`${TriggerEnums.NEW_CONTENTS}_${type}`] = data;
        PreferenceManager.getInstance().setValue(TriggerEnums.NEW_CONTENTS, record);
      }
      resolve();
    });
  }
}

interface NewContentParam extends BaseDetailParam {
  type: CardTypeEnum,
  version?: string,
  supportDevice?: string;
  apiVersion?: number;
}