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
import type { RatingDescriptor } from './RatingDescriptor';

@Observed
export class RatingAttributeModifier extends CommonAttributeModifier<RatingDescriptor, RatingAttribute> {
  public applyNormalAttribute(instance: RatingAttribute): void {
    this.assignAttribute((descriptor => descriptor.stars), (val) => instance.stars(Number(val)));
    this.assignAttribute((descriptor => descriptor.starStyle), (val) => instance.starStyle(Boolean(val) ?
      {
        backgroundUri: '/resources/base/media/rating_background.png',
        foregroundUri: '/resources/base/media/rating_foreground.png',
      } : {
        backgroundUri: undefined,
        foregroundUri: undefined,
      }));
  }
}