/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { PromptAction } from '@kit.ArkUI';
import { type BusinessError } from '@kit.BasicServicesKit';
import { StorageKey } from '../constant/CommonEnums';
import Logger from '../util/Logger';

const TAG: string = '[HMOS_Toast]';

class Toast {
  private longToastTime: number = 2000;

  public showToast(message: ResourceStr, duration?: number) {
    try {
      const uiContext: UIContext = AppStorage.get(StorageKey.UI_CONTEXT)!;
      const promptAction: PromptAction = uiContext.getPromptAction();
      promptAction.showToast({
        message: message,
        duration: duration,
      });
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
    }
  }

  public showLongToast(message: ResourceStr) {
    this.showToast(message, this.longToastTime);
  }
}

export default new Toast();