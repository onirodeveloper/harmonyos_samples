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
import type { TabDescriptor } from './TabDescriptor';

@Observed
export class TabAttributeModifier extends CommonAttributeModifier<TabDescriptor, TabsAttribute> {
  applyNormalAttribute(instance: TabsAttribute): void {
    this.assignAttribute((descriptor => descriptor.vertical), (val) => instance.vertical(val));
    this.assignAttribute((descriptor => descriptor.barWidth), (val) => instance.barWidth(val));
    this.assignAttribute((descriptor => descriptor.barHeight), (val) => instance.barHeight(val));
    this.assignAttribute((descriptor => descriptor.fadingEdge), (val) => instance.fadingEdge(val));
    this.assignAttribute((descriptor => descriptor.backgroundBlurStyle), (val) => instance.backgroundBlurStyle(val));
    this.assignAttribute((descriptor => descriptor.barPosition), (val) => instance.barPosition(val));
  }
}