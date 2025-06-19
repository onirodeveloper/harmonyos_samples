/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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
import { MockRequest, PreferenceManager } from '@ohos/common';
import type { DiscoverData } from '../model/DiscoverData';

export class DiscoverService {
  constructor() {
  }

  public getSampleListByMock(): Promise<DiscoverData> {
    return new Promise((resolve: (value: DiscoverData) => void,
      reject: (reason?: Object) => void) => {
      MockRequest.call<DiscoverData>(DiscoverTrigger.DISCOVER_PAGE)
        .then((result: Object) => {
          resolve(result as DiscoverData);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }

  getDiscoverPage(): Promise<DiscoverData> {
    return this.getSampleListByMock();
  }

  getDiscoveryPageByPreference(): Promise<DiscoverData> {
    return new Promise((resolve: (value: DiscoverData) => void,
      reject: (reason?: string) => void) => {
      PreferenceManager.getInstance()
        .getValue<Record<string, DiscoverData>>(DiscoverTrigger.DISCOVER_PAGE)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, DiscoverData>);
          const ret = resp[DiscoverTrigger.DISCOVER_PAGE];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        });
    });
  }

  setDiscoveryPageToPreference(data: DiscoverData): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(DiscoverTrigger.DISCOVER_PAGE)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, DiscoverData>>(DiscoverTrigger.DISCOVER_PAGE)
              .then((resp) => {
                resp = (resp as Record<string, DiscoverData>);
                resp[DiscoverTrigger.DISCOVER_PAGE] = data;
                PreferenceManager.getInstance().setValue(DiscoverTrigger.DISCOVER_PAGE, resp);
                resolve();
              });
          } else {
            const record: Record<string, DiscoverData> = {};
            record[DiscoverTrigger.DISCOVER_PAGE] = data;
            PreferenceManager.getInstance().setValue(DiscoverTrigger.DISCOVER_PAGE, record);
          }
        });
    });
  }
}

enum DiscoverTrigger {
  DISCOVER_PAGE = 'discovery-page',
  DISCOVER_ARTICLE = 'discovery-article',
}