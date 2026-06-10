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

const TAG: string = '[HMOS_AlertDialog]';

class AlertDialog {

  public showAlertDialogWhenXiaoYiFailed(uiContext?: UIContext) {
    try {
      Logger.info(TAG, `into @showAlertDialogWhenXiaoYiFailed()`)
      if (!uiContext) {
        uiContext = AppStorage.get(StorageKey.UI_CONTEXT);
      }
      if (!uiContext) {
        Logger.error(TAG, `@showAlertDialogWhenXiaoYiFailed: Show toast failed, cause uicontext is undefined`);
        return;
      }
      uiContext.showAlertDialog({
        'title': $r('app.string.intent_title_when_xiaoyi_extracted_no_keyword'),
        'message': $r('app.string.intent_hint_when_xiaoyi_extracted_no_keyword'),
        'autoCancel': false,
        'alignment': DialogAlignment.Center,
        'buttonDirection': DialogButtonDirection.HORIZONTAL,
        'buttons': [
          {
            'value': $r('app.string.intent_button_I_got_it'),
            'action': () => {}
          }
        ],
        'cancel': () => {},
        'onWillDismiss': (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
            dismissDialogAction.dismiss();
          } else if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
            dismissDialogAction.dismiss();
          } else if (dismissDialogAction.reason === DismissReason.CLOSE_BUTTON) {
            dismissDialogAction.dismiss();
          }
        }
      })
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Show alertDialog error, the code is ${error.code}, the message is ${error.message}`);
    }
  }
}

export default new AlertDialog();