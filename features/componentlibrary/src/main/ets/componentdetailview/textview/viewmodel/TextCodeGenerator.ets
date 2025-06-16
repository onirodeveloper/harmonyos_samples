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
import { fontWeightMapData } from '../../common/entity/CommonMapData';
import {
  fontColorMapData,
  fontSizeMapData,
  letterSpacingMapData,
  opacityMapData,
  textShadowRadiusMapData,
} from '../entity/TextAttributeMapping';

export class TextCodeGenerator implements CommonCodeGenerator {
  private fontWeight: string = fontWeightMapData.get('Default')!.code;
  private fontSize: string = fontSizeMapData.get('Default')!.code;
  private fontColor: string = fontColorMapData.get('Default')!.code;
  private opacity: string = opacityMapData.get('Default')!.code;
  private letterSpacing: string = letterSpacingMapData.get('Default')!.code;
  private textShadowRadius: string = textShadowRadiusMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    const text = '开发者你好';
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'fontWeight':
          this.fontWeight =
            fontWeightMapData.get(attribute.currentValue)?.code ?? fontWeightMapData.get('Default')!.code;
          break;
        case 'fontColor':
          this.fontColor = attribute.currentValue;
          break;
        case 'fontSize':
          this.fontSize = attribute.currentValue;
          break;
        case 'opacity':
          this.opacity = Number(attribute.currentValue).toString();
          break;
        case 'letterSpacing':
          this.letterSpacing = attribute.currentValue;
          break;
        case 'textShadowRadius':
          this.textShadowRadius = attribute.currentValue;
          break;
        default:
          break;
      }
    });
    return `@Component
struct TextComponent {
  build() {
    Text('${text}')
      .fontSize(${this.fontSize})
      .fontColor('${this.fontColor}')
      .fontWeight(${this.fontWeight})
      .opacity(${this.opacity})
      .letterSpacing(${this.letterSpacing})
      .textShadow({ radius: ${this.textShadowRadius} })
  }
}`;
  }
}