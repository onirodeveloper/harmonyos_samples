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
import {
  paddingNumMapData,
  rowAlignMapData,
  rowJustifyContentMapData,
  rowPaddingMapData,
  rowSpaceMapData,
} from '../entity/RowAttributeMapping';

@Observed
export class RowDescriptor extends CommonDescriptor {
  public alignItems: VerticalAlign = rowAlignMapData.get('Default')!.value;
  public flexAlign: FlexAlign = rowJustifyContentMapData.get('Default')!.value;
  public space: number = rowSpaceMapData.get('Default')!.value;
  public padding: string = rowPaddingMapData.get('Default')!.value;
  public paddingNum: number = paddingNumMapData.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'alignItems':
          this.alignItems = rowAlignMapData.get(attribute.currentValue)?.value ?? this.alignItems;
          break;
        case 'flexAlign':
          this.flexAlign = rowJustifyContentMapData.get(attribute.currentValue)?.value ?? this.flexAlign;
          break;
        case 'space':
          this.space = Number(attribute.currentValue);
          break;
        case 'padding':
          this.padding = attribute.currentValue;
          break;
        case 'paddingNum':
          this.paddingNum = Number(attribute.currentValue);
          break;
        default:
          break;
      }
    });
  }
}