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

import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { StorageKey } from '../constant/CommonEnums';
import { TriggerEnums } from '../constant/TriggerEnums';
import { ResponseData } from '../model/ResponseData';
import Logger from '../util/Logger';

const TAG = '[MockRequest]';

/**
 * Mock data request class.
 */
export class MockRequest {
  private static instance: MockRequest;

  private constructor() {
  }

  public static getInstance() {
    if (!MockRequest.instance) {
      MockRequest.instance = new MockRequest();
    }
    return MockRequest.instance;
  }

  public request<T>(trigger: TriggerEnums, param?: object): Promise<T> {
    return new Promise((resolve: (value: T | PromiseLike<T>) => void,
      reject: ((reason?: BusinessError) => void)) => {
      try {
        const uiContext: UIContext | undefined = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
        const context: Context | undefined = uiContext?.getHostContext();
        if (!uiContext || !context) {
          Logger.error(TAG, `GetRawFileContent failed, cause uiContext or context is undefined.`);
          reject({ message: 'uiContext or context is undefined.' } as BusinessError);
          return;
        }
        const result: Uint8Array = context.resourceManager.getRawFileContentSync(`mockdata/${trigger}.json`);
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        const content: string = textDecoder.decodeToString(result, { stream: false });
        Logger.info(TAG, `GetRawFileContent succeed.`);
        const requestParam: Record<string, string | number | object> = {};
        if (param) {
          Object.keys(param).forEach((key: string) => {
            requestParam[key] = param[key];
          });
        }
        // Detail data.
        if (requestParam['singleId']) {
          const jsonContent: ResponseData<(CommonBaseData<T> | SampleListData)[]> =
            JSON.parse(content) as ResponseData<(CommonBaseData<T> | SampleListData)[]>;
          const item =
            jsonContent.body.find((item: (CommonBaseData<T> | SampleListData)) => item.id ===
              requestParam['singleId'] as number);
          if (!item) {
            reject({ message: 'Not found details data' } as BusinessError);
            return;
          }

          // Sample need filter by deviceType and apiVersion.
          if (requestParam['supportDevice'] && requestParam['apiVersion']) {
            if (requestParam['cardId']) {
              // Sample details.
              const details =
                filterSamples(((item as CommonBaseData<T>)?.sampleContents as BaseSampleData[]), requestParam);
              resolve(details as T);
            } else if (requestParam['categoryId']) {
              // Sample list.
              const sampleList = (item as SampleListData).data as CommonBaseData<null>[];
              const list: CommonBaseData<null>[] = [];
              sampleList.forEach((sampleCard: CommonBaseData<null>) => {
                const sampleContents = filterSamples(sampleCard.sampleContents as BaseSampleData[], requestParam);
                if (sampleContents.length > 0) {
                  sampleCard.sampleContents = sampleContents;
                  list.push(sampleCard);
                }
              });
              (item as SampleListData).data = list;
              resolve(item as T);
            } else if (requestParam['type']) {
              // New Content sample list.
              const sampleList = (item as CommonBaseData<T>).data as BaseSampleData[];
              const listData = filterSamples(sampleList, requestParam);
              resolve(listData as T);
            }
          } else if (requestParam['type']) {
            resolve((item as CommonBaseData<T>).data as T);
          } else {
            resolve(item as T);
          }
        } else {
          const jsonContent: ResponseData<T> = JSON.parse(content) as ResponseData<T>;
          if (requestParam['supportDevice'] && requestParam['apiVersion']) {
            const data = jsonContent.body;
            resolve(data);
          } else {
            resolve(jsonContent.body);
          }
        }
      } catch (error) {
        Logger.error(TAG, `GetRawFileContent failed, error code: ${error.code}, message: ${error.message}.`);
        reject(error as BusinessError);
      }
    });
  }
}

interface CommonBaseData<T> {
  id: number;
  sampleContents?: T | BaseSampleData[];
  data?: T | BaseSampleData[];
}

interface BaseSampleData {
  supportDeviceList: string[],
  requiredApiVersion: number,
}

interface SampleListData {
  id: number;
  data: CommonBaseData<null>[];
}

function filterSamples(sampleContents: BaseSampleData[], requestParam: Record<string, string | number | object>) {
  return sampleContents.filter((sample: BaseSampleData) => {
    return sample.supportDeviceList.includes(String(requestParam['supportDevice'])) &&
      sample.requiredApiVersion <= requestParam['apiVersion'];
  });
}