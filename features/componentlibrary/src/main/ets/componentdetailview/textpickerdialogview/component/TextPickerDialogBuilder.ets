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

import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { TextPickerDialogDescriptor } from '../viewmodel/TextPickerDialogDescriptor';

const TAG: string = '[TextPickerDialogBuilder]';

@Builder
export function TextPickerDialogBuilder($$: DescriptorWrapper) {
  Column() {
    Button($r('app.string.text_picker_dialog_tip'))
      .margin($r('sys.float.padding_level10'))
      .buttonStyle(ButtonStyleMode.NORMAL)
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_emphasize'))
      .onClick(() => {
        TextPickerDialog.show({
          range: $r('app.strarray.text_picker_data'),
          defaultPickerItemHeight: ($$.descriptor as TextPickerDialogDescriptor).itemHeight,
          canLoop: ($$.descriptor as TextPickerDialogDescriptor).canLoop,
          onAccept: (value: TextPickerResult) => {
            try {
              promptAction.showToast({
                message: `Select ${value.value}`,
                duration: DetailPageConstant.LONG_DURATION
              });
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
            }
          },
          onCancel: () => {
            try {
              promptAction.showToast({
                message: 'Canceled',
                duration: DetailPageConstant.LONG_DURATION
              });
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
            }
          },
        });
      })
  }
  .width('100%')
}