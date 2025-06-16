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

import { LengthMetrics } from '@kit.ArkUI';
import { CommonAttributeModifier } from '../../../viewmodel/CommonAttributeModifier';
import type { TextAreaDescriptor } from './TextAreaDescriptor';

@Observed
export class TextAreaAttributeModifier extends CommonAttributeModifier<TextAreaDescriptor, TextAreaAttribute> {
  applyNormalAttribute(instance: TextAreaAttribute): void {
    this.assignAttribute((descriptor => descriptor.lineSpacing), (val) => instance.lineSpacing(LengthMetrics.vp(val)));
    this.assignAttribute((descriptor => descriptor.textOverflowTypeData), (val) => instance.textOverflow(val));
    this.assignAttribute((descriptor => descriptor.textAlign), (val) => instance.textAlign(val));
  }
}