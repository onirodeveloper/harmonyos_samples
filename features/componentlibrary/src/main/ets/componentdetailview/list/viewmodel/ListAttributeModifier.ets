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
import type { ListDescriptor } from './ListDescriptor';

@Observed
export class ListAttributeModifier extends CommonAttributeModifier<ListDescriptor, ListAttribute> {
  public applyNormalAttribute(instance: ListAttribute): void {
    this.assignAttribute((descriptor => descriptor.listDirection), (val) => instance.listDirection(val));
    this.assignAttribute((descriptor => descriptor.lanes), (val) => instance.lanes(val?.value, val?.gutter));
    this.assignAttribute((descriptor => descriptor.edgeEffect), (val) => instance.edgeEffect(val));
  }
}