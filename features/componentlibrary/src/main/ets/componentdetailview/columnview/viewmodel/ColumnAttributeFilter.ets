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

export class ColumnAttributeFilter implements CommonAttributeFilter {
  public filter(attributes: ObservedArray<Attribute>): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'padding':
          const paddingIndex = attributes.findIndex((item) => item.name === 'paddingNum');
          const flexAlignIndex = attributes.findIndex((item) => item.name === 'flexAlign');
          if (paddingIndex !== -1 && flexAlignIndex !== -1) {
            if (attribute.currentValue === 'None') {
              attributes[paddingIndex].enable = false;
              attributes[flexAlignIndex].enable = true;
            } else {
              attributes[paddingIndex].enable = true;
              attributes[flexAlignIndex].enable = false;
            }
          }
          break;
        case 'flexAlign':
          const spaceIndex = attributes.findIndex((item) => item.name === 'space');
          if (spaceIndex !== -1) {
            if (attribute.currentValue === 'SpaceBetween') {
              attributes[spaceIndex].enable = false;
            } else {
              attributes[spaceIndex].enable = true;
            }
          }
          break;
        default:
          break;
      }
    });
  }
}