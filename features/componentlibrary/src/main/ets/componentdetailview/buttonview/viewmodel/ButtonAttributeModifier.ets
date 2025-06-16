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

import type { ButtonDescriptor } from './ButtonDescriptor';
import { CommonAttributeModifier } from '../../../viewmodel/CommonAttributeModifier';

@Observed
export class ButtonAttributeModifier extends CommonAttributeModifier<ButtonDescriptor, ButtonAttribute> {
  public applyNormalAttribute(instance: ButtonAttribute): void {
    this.assignAttribute((descriptor => descriptor.buttonStyle), (val) => instance.buttonStyle(val));
    this.assignAttribute((descriptor => descriptor.controlSize), (val) => instance.controlSize(val));
    this.assignAttribute((descriptor => descriptor.buttonType), (val) => instance.type(val));
    this.assignAttribute((descriptor => descriptor.backgroundColor), (val) => instance.backgroundColor(val));
  }
}