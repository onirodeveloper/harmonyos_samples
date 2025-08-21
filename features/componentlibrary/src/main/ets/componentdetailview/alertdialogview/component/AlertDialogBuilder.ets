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

import { Logger, StorageKey, Toast } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { AlertDialogDescriptor } from '../viewmodel/AlertDialogDescriptor';

const TAG: string = '[AlertDialogBuilder]';

@Builder
export function AlertDialogBuilder($$: DescriptorWrapper) {
  Column({ space: DetailPageConstant.SPACE_SMALL }) {
    Button($r('app.string.alert_dialog_tip'))
      .buttonStyle(ButtonStyleMode.NORMAL)
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_emphasize'))
      .onClick(() => {
        const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
        uiContext.showAlertDialog(
          {
            title: $r('app.string.title'),
            subtitle: $r('app.string.subtitle'),
            message: $r('app.string.content'),
            autoCancel: true,
            alignment: ($$.descriptor as AlertDialogDescriptor).alertDialogAlignment,
            buttonDirection: DialogButtonDirection.HORIZONTAL,
            buttons: [
              {
                value: $r('app.string.button_one'),
                action: () => {
                  Toast.showLongToast('Callback when button1 is clicked');
                },
              },
              {
                value: $r('app.string.button_two'),
                action: () => {
                  Toast.showLongToast('Callback when button2 is clicked');
                },
              }
            ],
            cancel: () => {
              Logger.info(TAG, 'Closed callbacks');
            },
            onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
              if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                dismissDialogAction.dismiss();
              }
              if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                dismissDialogAction.dismiss();
              }
            },
          });
      })
  }
}