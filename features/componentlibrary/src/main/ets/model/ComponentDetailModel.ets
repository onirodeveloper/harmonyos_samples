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

import { Logger } from '@ohos/common';
import { ComponentLibraryService } from '../service/ComponentLibraryService';
import type { ComponentDetailData } from './ComponentDetailData';

const TAG = '[ComponentDetailModel]';

export class ComponentDetailModel {
  private static instance: ComponentDetailModel;
  private service: ComponentLibraryService = new ComponentLibraryService();

  private constructor() {
  }

  public static getInstance(): ComponentDetailModel {
    if (!ComponentDetailModel.instance) {
      ComponentDetailModel.instance = new ComponentDetailModel();
    }
    return ComponentDetailModel.instance;
  }

  public init(id: number): Promise<ComponentDetailData> {
    return this.service.getComponentDetailByPreference(id).then((data: ComponentDetailData) => {
      return data;
    }).catch((err: string) => {
      Logger.error(TAG, `get data from network failed! try to get data form preference. ${err}`);
      return this.service.getComponentDetail(id)
        .then((data: ComponentDetailData) => {
          this.service.setComponentDetailToPreference(id, data);
          return data;
        });
    });
  }
}