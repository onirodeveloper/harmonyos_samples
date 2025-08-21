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
import Logger from '../util/Logger';

const TAG = '[MockRequest]';

/**
 * Mock data request class.
 */
class MockRequest {
  public call<T>(trigger: string): Promise<T> {
    return new Promise((resolve: (value: T | PromiseLike<T>) => void,
      reject: ((reason?: BusinessError) => void)) => {
      try {
        const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
        const result: Uint8Array = uiContext.getHostContext()!.resourceManager.getRawFileContentSync(`mockdata/${trigger}.json`);
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        const content: string = textDecoder.decodeToString(result, { stream: false });
        const jsonContent: ResultData<T> = JSON.parse(content) as ResultData<T>;
        Logger.info(TAG, `GetRawFileContent failed, cause: no ${trigger} json is configured.`);
        resolve(jsonContent.data);
      } catch (error) {
        Logger.error(TAG, `GetRawFileContent failed, error code: ${error.code}, message: ${error.message}.`);
        reject(error);
      }
    });
  }
}

interface ResultData<T> {
  code: number;
  data: T;
  message: string;
}

const mockRequest = new MockRequest();

export default mockRequest;