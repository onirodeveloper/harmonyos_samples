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

import { CommonAttributeModifier } from '../../../viewmodel/CommonAttributeModifier';
import type { TextDescriptor } from './TextDescriptor';

@Observed
export class TextAttributeModifier extends CommonAttributeModifier<TextDescriptor, TextAttribute> {
  applyNormalAttribute(instance: TextAttribute): void {
    this.assignAttribute((descriptor => descriptor.fontWeight), (val) => instance.fontWeight(val));
    this.assignAttribute((descriptor => descriptor.fontSize), (val) => instance.fontSize(Number(val)));
    this.assignAttribute((descriptor => descriptor.fontColor), (val) => instance.fontColor(val));
    this.assignAttribute((descriptor => descriptor.opacity), (val) => instance.opacity(val));
    this.assignAttribute((descriptor => descriptor.letterSpacing), (val) => instance.letterSpacing(val));
    this.assignAttribute((descriptor => descriptor.textShadowRadius), (val) => instance.textShadow({ radius: val,
      color: $r('sys.color.ohos_id_color_foreground')}));
  }
}