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

import type { ObservedArray } from '@ohos/common';
import type { Attribute } from '../../../viewmodel/Attribute';
import { CommonAttributeFilter } from '../../../viewmodel/CommonAttributeFilter';

export class StackAttributeFilter implements CommonAttributeFilter {
  filter(attributes: ObservedArray<Attribute>): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'alignDirection':
          const topIndex = attributes.findIndex((item) => item.name === 'alignContentTop');
          const centerIndex = attributes.findIndex((item) => item.name === 'alignContentCenter');
          const bottomIndex = attributes.findIndex((item) => item.name === 'alignContentBottom');
          if (topIndex !== -1 && centerIndex !== -1 && bottomIndex !== -1) {
            if (attribute.currentValue === 'Top') {
              attributes[topIndex].enable = true;
              attributes[centerIndex].enable = false;
              attributes[bottomIndex].enable = false;
            } else if (attribute.currentValue === 'Center') {
              attributes[topIndex].enable = false;
              attributes[centerIndex].enable = true;
              attributes[bottomIndex].enable = false;
            } else if (attribute.currentValue === 'Bottom') {
              attributes[topIndex].enable = false;
              attributes[centerIndex].enable = false;
              attributes[bottomIndex].enable = true;
            }
          }
          break;
        default:
          break;
      }
    });
  }
}