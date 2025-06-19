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
import type { WaterFlowDescriptor } from './WaterFlowDescriptor';

@Observed
export class WaterFlowAttributeModifier extends CommonAttributeModifier<WaterFlowDescriptor, WaterFlowAttribute> {
  applyNormalAttribute(instance: WaterFlowAttribute): void {
    this.assignAttribute((descriptor => descriptor.layoutDirection), (val) => instance.layoutDirection(val));
    this.assignAttribute((descriptor => descriptor.friction), (val) => instance.friction(Number(val)));
    this.assignAttribute((descriptor => descriptor.columnsTemplate), (val) => instance.columnsTemplate(val));
    this.assignAttribute((descriptor => descriptor.rowsTemplate), (val) => instance.rowsTemplate(val));
    this.assignAttribute((descriptor => descriptor.columnsGap), (val) => instance.columnsGap(val));
  }
}