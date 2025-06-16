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
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import {
  paddingNumMapData,
  rowAlignMapData,
  rowJustifyContentMapData,
  rowPaddingMapData,
  rowSpaceMapData,
} from '../entity/RowAttributeMapping';

export class RowCodeGenerator implements CommonCodeGenerator {
  private alignItems: string = rowAlignMapData.get('Default')!.code;
  private flexAlign: string = rowJustifyContentMapData.get('Default')!.code;
  private space: string = rowSpaceMapData.get('Default')!.code;
  private padding: string = rowPaddingMapData.get('Default')!.code;
  private paddingNum: string = paddingNumMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'alignItems':
          this.alignItems = rowAlignMapData.get(attribute.currentValue)?.code ?? this.alignItems;
          break;
        case 'flexAlign':
          this.flexAlign = rowJustifyContentMapData.get(attribute.currentValue)?.code ?? this.flexAlign;
          break;
        case 'space':
          this.space = attribute.currentValue;
          break;
        case 'padding':
          this.padding = attribute.currentValue;
          break;
        case 'paddingNum':
          this.paddingNum = attribute.currentValue;
          break;
        default:
          break;
      }
    });

    let codeStr = '';
    if (this.padding === 'Vertical') {
      codeStr = `.padding({
      top: ${this.paddingNum},
      bottom: ${this.paddingNum}
    })`;
    } else if (this.padding === 'Horizontal') {
      codeStr = `.padding({
      left: ${this.paddingNum},
      right: ${this.paddingNum}
    })`;
    } else {
      codeStr = `.padding(${this.paddingNum})`;
    }

    return `@Component
struct RowComponent {
  build() {
    Row({ space: ${this.space} }) {
      Column()
        .size({ width: 40, height: 40 })
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .borderRadius($r('sys.float.corner_radius_level4'))
      Column()
        .size({ width: 52, height: 52 })
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .borderRadius($r('sys.float.corner_radius_level4'))
      Column()
        .size({ width: 64, height: 64 })
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .borderRadius($r('sys.float.corner_radius_level4'))
    }
    .width('${this.padding === 'None' ? '80%' : 'auto'}')
    .height('${this.padding === 'None' ? '50%' : 'auto'}')
    ${codeStr}
    .alignItems(${this.alignItems})
    .justifyContent(${this.flexAlign})
    .borderRadius($r('sys.float.corner_radius_level6'))
    .border({ width: 1, color: $r('sys.color.comp_background_emphasize') })
  }
}`;
  }
}