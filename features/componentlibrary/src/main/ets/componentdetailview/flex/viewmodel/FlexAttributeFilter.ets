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

import { ObservedArray } from '@ohos/common';
import type { Attribute } from '../../../viewmodel/Attribute';
import { CommonAttributeFilter } from '../../../viewmodel/CommonAttributeFilter';

export class FlexAttributeFilter implements CommonAttributeFilter {
  public filter(attributes: ObservedArray<Attribute>): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'wrap':
          const alignSelfIndex = attributes.findIndex((item) => item.name === 'alignSelf');
          const alignContentIndex = attributes.findIndex((item) => item.name === 'alignContent');
          if (alignSelfIndex !== -1 && alignContentIndex !== -1) {
            if (attribute.currentValue === 'Wrap' || attribute.currentValue === 'WrapReverse') {
              attributes[alignSelfIndex].enable = false;
              attributes[alignContentIndex].enable = true;
            } else if (attribute.currentValue === 'NoWrap') {
              attributes[alignSelfIndex].enable = true;
              attributes[alignContentIndex].enable = false;
            }
          }
          break;
        default:
          break;
      }
    });
  }
}