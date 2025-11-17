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

import { Logger, ResponseData } from '@ohos/common';
import { MineService } from '../service/MineService';
import { AllContentData } from './AllContentData';
import { MineTrigger, NewContentData } from './NewContentData';

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

  public getNewContent(type: MineTrigger, currentPage: number,
    pageSize: number): Promise<ResponseData<NewContentData[]>> {
    return this.service.getNewContentByPreference(type, currentPage, pageSize)
      .then((data: ResponseData<NewContentData[]>) => {
        return data;
      }).catch((err: string) => {
        Logger.error(TAG,
          `getNewContent data from network failed! try to get data form preference. ${err}`);
        return this.service.getNewContent(type, currentPage, pageSize)
          .then((data: ResponseData<NewContentData[]>) => {
            this.service.setNewContentToPreference(type, data);
            return data;
          });
      });
  }

  public getNewContentNumber(type: MineTrigger): Promise<AllContentData> {
    return this.service.getNewContentNumByPreference(type)
      .then((data: AllContentData) => {
        return data;
      }).catch((err: string) => {
        Logger.error(TAG,
          `getNewContent data from network failed! try to get data form preference. ${err}`);
        return this.service.getNewContentNumByMock(type)
          .then((data: AllContentData) => {
            this.service.setNewContentNumToPreference(type, data);
            return data;
          });
      });
  }
}