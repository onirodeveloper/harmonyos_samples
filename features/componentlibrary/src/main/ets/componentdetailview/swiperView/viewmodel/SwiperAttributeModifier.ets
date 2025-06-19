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
import type { SwiperDescriptor } from './SwiperDescriptor';

@Observed
export class SwiperAttributeModifier extends CommonAttributeModifier<SwiperDescriptor, SwiperAttribute> {
  applyNormalAttribute(instance: SwiperAttribute): void {
    this.assignAttribute((descriptor => descriptor.indicator), (val) => instance.indicator(val));
    this.assignAttribute((descriptor => descriptor.vertical), (val) => instance.vertical(val));
    this.assignAttribute((descriptor => descriptor.effectMode), (val) => instance.effectMode(val));
    this.assignAttribute((descriptor => descriptor.displayArrow), (val) => instance.displayArrow(val));
    this.assignAttribute((descriptor => descriptor.loop), (val) => instance.autoPlay(val));
  }
}