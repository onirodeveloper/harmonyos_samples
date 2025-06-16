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
import type { ComponentData } from '../model/ComponentData';
import type { ComponentDetailData } from '../model/ComponentDetailData';

const TAG = '[ComponentLibraryService]';

export class ComponentLibraryService {
  private static readonly MAIN_PAGE_DATA = 'COMPONENT_LIBRARY_MAIN_PAGE_DATA';
  private static readonly DETAIL_PAGE_DATA = 'COMPONENT_LIBRARY_DETAIL_PAGE_DATA';

  constructor() {
  }

  public getComponentListByMock(): Promise<ResponseData<ComponentData>> {
    return new Promise((resolve: (value: ResponseData<ComponentData>) => void,
      reject: (reason?: Object) => void) => {
      MockRequest.call<ResponseData<ComponentData>>(ComponentLibraryTrigger.COMPONENT_PAGE)
        .then((result: Object) => {
          resolve(result as ResponseData<ComponentData>);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getComponentList(currentPage?: number, pageSize?: number): Promise<ResponseData<ComponentData>> {
    Logger.info(TAG, `getComponentList param: currentPage ${currentPage}, pageSize: ${pageSize} `);
    return this.getComponentListByMock();
  }

  public getComponentListByPreference(currentPage: number, pageSize: number): Promise<ResponseData<ComponentData>> {
    return new Promise((resolve: (value: ResponseData<ComponentData>) => void,
      reject: (reason?: string) => void) => {
      PreferenceManager.getInstance()
        .getValue<Record<string, ResponseData<ComponentData>>>(ComponentLibraryService.MAIN_PAGE_DATA)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, ResponseData<ComponentData>>);
          const ret = resp[`${currentPage}_${pageSize}`];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `get getComponentListByPreference failed, error: ${error.code}, ${error.message}`);
          reject(error.message);
        });
    });
  }

  public setComponentListToPreference(data: ResponseData<ComponentData>): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(ComponentLibraryService.MAIN_PAGE_DATA)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, ResponseData<ComponentData>>>(ComponentLibraryService.MAIN_PAGE_DATA)
              .then((resp) => {
                resp = (resp as Record<string, ResponseData<ComponentData>>);
                resp[`${data.currentPage}_${data.pageSize}`] = data;
                PreferenceManager.getInstance().setValue(ComponentLibraryService.MAIN_PAGE_DATA, resp);
                resolve();
              });
          } else {
            const record: Record<string, ResponseData<ComponentData>> = {};
            record[`${data.currentPage}_${data.pageSize}`] = data;
            PreferenceManager.getInstance().setValue(ComponentLibraryService.MAIN_PAGE_DATA, record);
          }
        });
    });
  }

  public getComponentDetail(componentId: number): Promise<ComponentDetailData> {
    return new Promise((resolve: (value: ComponentDetailData) => void, reject: (reason?: Object) => void) => {
      this.getComponentDetailListByMock().then((result: ComponentDetailData[]) => {
        const item = result.find((item: ComponentDetailData) => item.id === componentId);
        if (item !== undefined) {
          resolve(item);
        } else {
          Logger.error(TAG, `getComponentDetailListByMock failed, error: can't find detail data by id ${componentId}`);
          reject();
        }
      });
    });
  }

  public getComponentDetailByPreference(componentId: number): Promise<ComponentDetailData> {
    return new Promise((resolve: (value: ComponentDetailData) => void,
      reject: (reason?: Object) => void) => {
      PreferenceManager.getInstance()
        .getValue<Record<string, ComponentDetailData>>(ComponentLibraryService.DETAIL_PAGE_DATA)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, ComponentDetailData>)
          const ret = resp[String(componentId)];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        });
    });
  }

  public setComponentDetailToPreference(componentId: number, data: ComponentDetailData): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(ComponentLibraryService.DETAIL_PAGE_DATA)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, ComponentDetailData>>(ComponentLibraryService.DETAIL_PAGE_DATA)
              .then((resp) => {
                resp = (resp as Record<string, ComponentDetailData>);
                resp[String(componentId)] = data;
                PreferenceManager.getInstance().setValue(ComponentLibraryService.DETAIL_PAGE_DATA, resp);
                resolve();
              })
          } else {
            const record: Record<string, ComponentDetailData> = {};
            record[String(componentId)] = data;
            PreferenceManager.getInstance().setValue(ComponentLibraryService.DETAIL_PAGE_DATA, record);
          }
        });
    });
  }

  public setDetailsToPreference(details: ComponentDetailData[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(ComponentLibraryService.DETAIL_PAGE_DATA)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, ComponentDetailData>>(ComponentLibraryService.DETAIL_PAGE_DATA)
              .then((resp: Record<string, ComponentDetailData> | null) => {
                const record: Record<string, ComponentDetailData> = resp || {};
                details.forEach((detail: ComponentDetailData) => {
                  record[String(detail.id)] = detail;
                })
                PreferenceManager.getInstance().setValue(ComponentLibraryService.DETAIL_PAGE_DATA, record);
                resolve();
              })
          } else {
            const record: Record<string, ComponentDetailData> = {};
            details.forEach((detail: ComponentDetailData) => {
              record[String(detail.id)] = detail;
            });
            PreferenceManager.getInstance().setValue(ComponentLibraryService.DETAIL_PAGE_DATA, record);
          }
        });
    });
  }

  public getComponentDetailListByMock(): Promise<ComponentDetailData[]> {
    return new Promise((resolve: (value: ComponentDetailData[]) => void,
      reject: (reason?: Object) => void) => {
      MockRequest.call<ComponentDetailData[]>(ComponentLibraryTrigger.COMPONENT_DETAIL_LIST)
        .then((result: ComponentDetailData[]) => {
          const details: ComponentDetailData[] = result as ComponentDetailData[];
          this.setDetailsToPreference(details);
          resolve(result as ComponentDetailData[]);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  public getComponentDetailList(): Promise<ComponentDetailData[]> {
    return this.getComponentDetailListByMock();
  }
}

enum ComponentLibraryTrigger {
  COMPONENT_PAGE = 'component-page',
  COMPONENT_DETAIL = 'component-details',
  COMPONENT_DETAIL_LIST = 'file-data',
  CODELAB_DETAIL = 'codelab-details',
}