/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import { pasteboard } from '@kit.BasicServicesKit';
import Toast from '../component/Toast';
import Logger from './Logger';

const TAG: string = '[PasteboardUtil]';

export class PasteboardUtil {
  public static copyText(text: string) {
    try {
      const pasteboardData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData).then(() => {
        Toast.showToast($r('app.string.copy_success'))
      }).catch((error: BusinessError) => {
        Toast.showToast($r('app.string.copy_fail'));
        Logger.error(TAG, `Copy data failed, the code is ${error.code}, the message is ${error.message}`);
      })
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Pasteboard invoke error, the code is ${error.code}, the message is ${error.message}`);
    }
  }
}
