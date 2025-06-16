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

import { CommonAttributeModifier } from '../../../../viewmodel/CommonAttributeModifier';
import type { CalendarPickerDescriptor } from './CalendarPickerDescriptor';

@Observed
export class CalendarPickerAttributeModifier extends CommonAttributeModifier<CalendarPickerDescriptor,
CalendarPickerAttribute> {
  public applyNormalAttribute(instance: CalendarPickerAttribute): void {
    this.assignAttribute((descriptor => descriptor.edgeAlign),
      (val) => instance.edgeAlign(val?.alignType, val?.offset));
    this.assignAttribute((descriptor => descriptor.textStyle), (val) => instance.textStyle(val));
  }
}
