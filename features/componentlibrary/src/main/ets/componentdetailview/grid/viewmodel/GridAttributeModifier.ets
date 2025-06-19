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
import type { GridDescriptor } from './GridDescriptor';

@Observed
export class GridAttributeModifier extends CommonAttributeModifier<GridDescriptor, GridAttribute> {
  public applyNormalAttribute(instance: GridAttribute): void {
    this.assignAttribute((descriptor => descriptor.columnsGap), (val) => instance.columnsGap(val));
    this.assignAttribute((descriptor => descriptor.rowsGap), (val) => instance.rowsGap(val));
    this.assignAttribute((descriptor => descriptor.columnsTemplate), (val) => instance.columnsTemplate(val));
    this.assignAttribute((descriptor => descriptor.rowsTemplate), (val) => instance.rowsTemplate(val));
    this.assignAttribute((descriptor => descriptor.operationMode), (val) => instance.editMode(val));
  }
}