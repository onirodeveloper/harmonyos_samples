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
import { stackAlignMapData } from '../entity/StackAttributeMapping';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class StackCodeGenerator implements CommonCodeGenerator {
  private alignContent: string = stackAlignMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    const index: number = attributes.findIndex((item) => item.name === 'alignDirection');
    let alignDirection: string = '';
    if (index >= 0) {
      alignDirection = attributes[index].currentValue;
    }
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'alignContentTop':
          if (alignDirection === 'Top') {
            this.alignContent = stackAlignMapData.get(attribute.currentValue)?.code ?? this.alignContent;
          }
          break;
        case 'alignContentCenter':
          if (alignDirection === 'Center') {
            this.alignContent = stackAlignMapData.get(attribute.currentValue)?.code ?? this.alignContent;
          }
          break;
        case 'alignContentBottom':
          if (alignDirection === 'Bottom') {
            this.alignContent = stackAlignMapData.get(attribute.currentValue)?.code ?? this.alignContent;
          }
          break;
        default:
          break;
      }
    });
    return `@Component
struct StackComponent {
  build() {
    Stack({ alignContent: ${this.alignContent} }){
      Column()
        .size({ width: 92, height: 92 })
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .borderRadius($r('sys.float.corner_radius_level4'))
      Column()
        .size({ width: 64, height: 64 })
        .backgroundColor($r('sys.color.multi_color_03'))
        .borderRadius($r('sys.float.corner_radius_level4'))
    }
    .padding($r('sys.float.padding_level3'))
    .height('180vp')
    .width('262vp')
    .border({
      width: '1vp',
      color: $r('sys.color.comp_background_emphasize'),
      radius: $r('sys.float.corner_radius_level6')
    })
  }
}`;
  }
}