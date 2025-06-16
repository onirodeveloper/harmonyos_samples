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

import type { DescriptorWrapper } from '../../../../viewmodel/DescriptorWrapper';
import { DatePickerAttributeModifier } from '../viewmodel/DatePickerAttributeModifier';
import type { DatePickerDescriptor } from '../viewmodel/DatePickerDescriptor';

@Builder
export function DatePickerBuilder($$: DescriptorWrapper) {
  Column() {
    DatePicker({
      start: new Date('1970-1-1'),
      end: new Date('2100-1-1'),
      selected: new Date('2021-08-08'),
    })
      .margin({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
        top: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8'),
      })
      .selectedTextStyle(($$.descriptor as DatePickerDescriptor).selectedTextStyle)
      .textStyle(($$.descriptor as DatePickerDescriptor).textStyle)
      .attributeModifier(new DatePickerAttributeModifier($$.descriptor as DatePickerDescriptor))
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}