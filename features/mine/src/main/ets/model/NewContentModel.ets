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

import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { CardTypeEnum } from '@ohos/commonbusiness';
import { MineService } from '../service/MineService';
import { NewContentData } from './NewContentData';

const TAG = '[NewContentModel]';

export class NewContentModel {
  private static instance: NewContentModel;
  private service: MineService = new MineService();

  private constructor() {
  }

  public static getInstance(): NewContentModel {
    if (!NewContentModel.instance) {
      NewContentModel.instance = new NewContentModel();
    }
    return NewContentModel.instance;
  }

  public getNewContent(type: CardTypeEnum): Promise<NewContentData[]> {
    return new Promise((resolve, reject) => {
      this.service.getNewContent(type)
        .then((data: NewContentData[]) => {
          this.service.setNewContentToPreference(type, data);
          resolve(data);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG,
            `getNewContent from network failed! Retried form preference. code: ${err.code}; message: ${err.message}`);
          this.service.getNewContentByPreference(type)
            .then((data: NewContentData[]) => {
              resolve(data);
            })
            .catch(() => {
              reject(err);
            });
        });
    });
  }
}