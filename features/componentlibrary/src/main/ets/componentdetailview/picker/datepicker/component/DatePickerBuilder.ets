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

const START_DATE: string = '1970-1-1';
const END_DATE: string = '2100-1-1';
const SELECTED_DATE: string = '2021-08-08';

@Builder
export function DatePickerBuilder($$: DescriptorWrapper) {
  Column() {
    DatePicker({
      start: new Date(START_DATE),
      end: new Date(END_DATE),
      selected: new Date(SELECTED_DATE),
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