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
import { ComponentLibraryService } from '../service/ComponentLibraryService';
import type { ComponentData } from './ComponentData';
import { ComponentDetailData } from './ComponentDetailData';
import { componentDetailConfig } from '../componentdetailview/ComponentDetailConfig';

const TAG = '[ComponentListModel]';

export class ComponentListModel {
  private service: ComponentLibraryService = new ComponentLibraryService();
  private static instance: ComponentListModel;

  private constructor() {
  }

  public static getInstance(): ComponentListModel {
    if (!ComponentListModel.instance) {
      ComponentListModel.instance = new ComponentListModel();
    }
    return ComponentListModel.instance;
  }

  public getComponentPage(currentPage: number, pageSize: number): Promise<ResponseData<ComponentData>> {
    return this.service.getComponentListByPreference(currentPage, pageSize)
      .then((data: ResponseData<ComponentData>) => {
        return data;
      }).catch((err: string) => {
        Logger.error(TAG,
          `getComponentPage data from network failed! try to get data form preference. ${err}`);
        return this.service.getComponentList(currentPage, pageSize)
          .then((data: ResponseData<ComponentData>) => {
            this.service.setComponentListToPreference(data);
            return data;
          });
      });
  }

  public preloadComponentData(): Promise<void> {
    AppStorage.setOrCreate('componentDetailConfig', componentDetailConfig);
    this.service.getComponentDetailList().then((detailList: ComponentDetailData[]) => {
      this.service.setDetailsToPreference(detailList);
    });
    return this.service.getComponentList()
      .then((result: ResponseData<ComponentData>) => {
        this.service.setComponentListToPreference(result);
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `preloadComponentPage data from network failed. ${err.code}, ${err.message}`);
      });
  }
}