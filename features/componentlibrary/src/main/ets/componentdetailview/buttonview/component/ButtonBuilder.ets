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
import { ButtonAttributeModifier } from '../viewmodel/ButtonAttributeModifier';
import type { ButtonDescriptor } from '../viewmodel/ButtonDescriptor';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';

const TAG: string = '[ButtonBuilder]';

@Builder
export function ButtonBuilder($$: DescriptorWrapper) {
  Button($r('app.string.button_text'))
    .onClick(() => {
      if (($$.descriptor as ButtonDescriptor).operation === 'Click') {
        Toast.showLongToast($r('app.string.btn_click'));
      }
    })
    .gesture(
      LongPressGesture({ repeat: true })
        .onActionEnd((_event: GestureEvent) => {
          if (($$.descriptor as ButtonDescriptor).operation === 'LongGesture') {
            Toast.showLongToast($r('app.string.button_text2'));
          }
        })
    )
    .attributeModifier(new ButtonAttributeModifier($$.descriptor as ButtonDescriptor))
}