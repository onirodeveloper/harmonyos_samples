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

import { Toast } from '@ohos/common';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { TextPickerDialogDescriptor } from '../viewmodel/TextPickerDialogDescriptor';

@Builder
export function TextPickerDialogBuilder($$: DescriptorWrapper) {
  TextPickerDialogComponent({ textPickerDialogDescriptor: $$.descriptor as TextPickerDialogDescriptor })
}

@Component
struct TextPickerDialogComponent {
  @Prop textPickerDialogDescriptor: TextPickerDialogDescriptor;

  build() {
    Column() {
      Button($r('app.string.text_picker_dialog_tip'))
        .margin($r('sys.float.padding_level10'))
        .buttonStyle(ButtonStyleMode.NORMAL)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          this.getUIContext().showTextPickerDialog({
            range: $r('app.strarray.text_picker_data'),
            defaultPickerItemHeight: this.textPickerDialogDescriptor.itemHeight,
            canLoop: this.textPickerDialogDescriptor.canLoop,
            onAccept: (value: TextPickerResult) => {
              Toast.showLongToast(`Select ${value.value}`);
            },
            onCancel: () => {
              Toast.showLongToast('Canceled');
            },
          });
        })
    }
    .width('100%')
  }
}