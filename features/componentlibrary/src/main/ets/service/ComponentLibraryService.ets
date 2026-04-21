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
import type { PageData } from '@ohos/common';
import { HmosRequest, Logger, PreferenceManager, TriggerEnums } from '@ohos/common';
import { BannerData, BannerTypeEnum, BaseDetailParam, BaseListParam } from '@ohos/commonbusiness';
import type { ComponentData } from '../model/ComponentData';
import type { ComponentDetailData } from '../model/ComponentDetailData';

const TAG = '[ComponentLibraryService]';

export class ComponentLibraryService {
  private static readonly MAIN_PAGE_DATA = 'COMPONENT_LIBRARY_MAIN_PAGE_DATA';
  private static readonly DETAIL_PAGE_DATA = 'COMPONENT_LIBRARY_DETAIL_PAGE_DATA';

  constructor() {
  }

  public getComponentBanner(): Promise<BannerData[]> {
    const param: ComponentBannerParam = {
      moduleType: BannerTypeEnum.COMPONENT
    };
    return new Promise((resolve: (value: BannerData[]) => void,
      reject: (reason?: Object) => void) => {
      HmosRequest.getInstance().request<BannerData[]>(TriggerEnums.COMPONENT_BANNER, param)
        .then((result: Object) => {
          Logger.info(TAG, JSON.stringify(result));
          resolve(result as BannerData[]);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getComponentBanner failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  public getComponentBannerByPreference(): Promise<BannerData[]> {
    return new Promise((resolve: (value: BannerData[]) => void,
      reject: (e?: BusinessError) => void) => {
      let resp = PreferenceManager.getInstance()
        .getValue<Record<string, BannerData[]>>(ComponentLibraryService.MAIN_PAGE_DATA);
      if (!resp) {
        reject({ message: 'There is no data in the Preference' } as BusinessError);
        return;
      }
      resp = (resp as Record<string, BannerData[]>);
      const ret = resp[`component_banner`];
      if (!ret) {
        reject({ message: 'There is no data in the Preference' } as BusinessError);
        return;
      }
      resolve(ret);
    });
  }

  public setComponentBannerToPreference(data: BannerData[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(ComponentLibraryService.MAIN_PAGE_DATA);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<Record<string, BannerData[]>>(ComponentLibraryService.MAIN_PAGE_DATA) ?? {};
        resp = (resp as Record<string, BannerData[]>);
        resp[`component_banner`] = data;
        PreferenceManager.getInstance().setValue(ComponentLibraryService.MAIN_PAGE_DATA, resp);
      } else {
        const record: Record<string, BannerData[]> = {};
        record[`component_banner`] = data;
        PreferenceManager.getInstance().setValue(ComponentLibraryService.MAIN_PAGE_DATA, record);
      }
      resolve();
    });
  }

  public getComponentList(currentPage: number, pageSize: number): Promise<PageData<ComponentData>> {
    Logger.info(TAG, `getComponentList param: currentPage ${currentPage}, pageSize: ${pageSize} `);
    const param: ComponentListParam = {
      currentPage: currentPage,
      pageSize: pageSize,
    };
    return new Promise((resolve: (value: PageData<ComponentData>) => void,
      reject: (reason?: Object) => void) => {
      HmosRequest.getInstance().request<PageData<ComponentData>>(TriggerEnums.COMPONENT_PAGE, param)
        .then((result: Object) => {
          resolve(result as PageData<ComponentData>);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getComponentList failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  public getComponentListByPreference(currentPage: number, pageSize: number): Promise<PageData<ComponentData>> {
    return new Promise((resolve: (value: PageData<ComponentData>) => void,
      reject: (e?: BusinessError) => void) => {
      let resp = PreferenceManager.getInstance()
        .getValue<Record<string, PageData<ComponentData>>>(ComponentLibraryService.MAIN_PAGE_DATA);
      if (!resp) {
        reject({ message: 'There is no data in the Preference' } as BusinessError);
        return;
      }
      resp = (resp as Record<string, PageData<ComponentData>>);
      const ret = resp[`${currentPage}_${pageSize}`];
      if (!ret) {
        reject({ message: 'There is no data in the Preference' } as BusinessError);
        return;
      }
      resolve(ret);
    });
  }

  public setComponentListToPreference(data: PageData<ComponentData>): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(ComponentLibraryService.MAIN_PAGE_DATA);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<Record<string, PageData<ComponentData>>>(ComponentLibraryService.MAIN_PAGE_DATA) ?? {};
        resp = (resp as Record<string, PageData<ComponentData>>);
        resp[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(ComponentLibraryService.MAIN_PAGE_DATA, resp);
      } else {
        const record: Record<string, PageData<ComponentData>> = {};
        record[`${data.currentPage}_${data.pageSize}`] = data;
        PreferenceManager.getInstance().setValue(ComponentLibraryService.MAIN_PAGE_DATA, record);
      }
      resolve();
    });
  }

  public getComponentDetail(componentId: number) {
    const param: ComponentDetailParam = {
      componentId,
      singleId: componentId,
    };
    return new Promise((resolve: (value: ComponentDetailData) => void, reject: (reason?: Object) => void) => {
      HmosRequest.getInstance().request<ComponentDetailData>(TriggerEnums.COMPONENT_DETAIL, param)
        .then((result: ComponentDetailData) => {
          resolve(result);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `getComponentDetail failed. cause: ${error.message}`);
          reject(error);
        });
    });
  }

  public getComponentDetailByPreference(componentId: number): Promise<ComponentDetailData> {
    return new Promise((resolve: (value: ComponentDetailData) => void,
      reject: (reason?: Object) => void) => {
      let resp = PreferenceManager.getInstance()
        .getValue<Record<string, ComponentDetailData>>(ComponentLibraryService.DETAIL_PAGE_DATA);
      if (!resp) {
        reject('There is no data in the Preference');
        return;
      }
      resp = (resp as Record<string, ComponentDetailData>)
      const ret = resp[String(componentId)];
      if (!ret) {
        reject('There is no data in the Preference');
        return;
      }
      resolve(ret);
    });
  }

  public setComponentDetailToPreference(componentId: number, data: ComponentDetailData): Promise<void> {
    return new Promise((resolve: () => void) => {
      const hasValue: boolean = PreferenceManager.getInstance().hasValue(ComponentLibraryService.DETAIL_PAGE_DATA);
      if (hasValue) {
        let resp = PreferenceManager.getInstance()
          .getValue<Record<string, ComponentDetailData>>(ComponentLibraryService.DETAIL_PAGE_DATA);
        resp = (resp as Record<string, ComponentDetailData>);
        resp[String(componentId)] = data;
        PreferenceManager.getInstance().setValue(ComponentLibraryService.DETAIL_PAGE_DATA, resp);
      } else {
        const record: Record<string, ComponentDetailData> = {};
        record[String(componentId)] = data;
        PreferenceManager.getInstance().setValue(ComponentLibraryService.DETAIL_PAGE_DATA, record);
      }
      resolve();
    });
  }
}

interface ComponentListParam extends BaseListParam {}

interface ComponentBannerParam {
  moduleType: number;
}

interface ComponentDetailParam extends BaseDetailParam {
  componentId: number;
}