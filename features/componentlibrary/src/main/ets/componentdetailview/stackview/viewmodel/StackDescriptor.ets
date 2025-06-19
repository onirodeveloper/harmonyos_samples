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

import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';
import { stackAlignMapData } from '../entity/StackAttributeMapping';

@Observed
export class StackDescriptor extends CommonDescriptor {
  public alignContent: Alignment = stackAlignMapData.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    const index: number = attributes.findIndex((item) => item.name === 'alignDirection');
    let alignDirection: string = '';
    if (index >= 0) {
      alignDirection = attributes[index].currentValue;
    }
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'alignContentTop':
          if (alignDirection === 'Top') {
            this.alignContent = stackAlignMapData.get(attribute.currentValue)?.value ?? this.alignContent;
          }
          break;
        case 'alignContentCenter':
          if (alignDirection === 'Center') {
            this.alignContent = stackAlignMapData.get(attribute.currentValue)?.value ?? this.alignContent;
          }
          break;
        case 'alignContentBottom':
          if (alignDirection === 'Bottom') {
            this.alignContent = stackAlignMapData.get(attribute.currentValue)?.value ?? this.alignContent;
          }
          break;
        default:
          break;
      }
    });
  }
}