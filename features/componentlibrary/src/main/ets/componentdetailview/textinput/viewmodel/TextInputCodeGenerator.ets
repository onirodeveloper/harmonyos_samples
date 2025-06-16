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
import { highlightColorMap } from '../../common/entity/CommonMapData';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import { textInputFontMapData, textInputTypeMapData } from '../entity/TextInputAttributeMapping';

export class TextInputCodeGenerator implements CommonCodeGenerator {
  private typeStr: string = textInputTypeMapData.get('Default')!.code;
  private fontColor: string = highlightColorMap.get('Default')!.code;
  private placeholderFont: string = textInputFontMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'type':
          this.typeStr =
            textInputTypeMapData.get(attribute.currentValue)?.code ?? textInputTypeMapData.get('Default')!.code;
          break;
        case 'fontColor':
          this.fontColor = attribute.currentValue;
          break;
        case 'placeholderFont':
          this.placeholderFont =
            textInputFontMapData.get(attribute.currentValue)?.code ?? textInputFontMapData.get('Default')!.code;
          break;
        default:
          break;
      }
    });

    return `@Component
struct TextInputComponent {
  build() {
   Column() {
    TextInput({ text: '开发者你好', placeholder: '请输入' })
      .margin({ left: 36, right: 36 })
      .height(48)
      .enterKeyType(EnterKeyType.Done)
      .borderRadius($r('sys.float.corner_radius_level12'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Regular)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .caretStyle({ color: $r('sys.color.font_emphasize') })
      .type(${this.typeStr})
      .fontColor('${this.fontColor}')
      .placeholderFont(${this.placeholderFont})\n
    }
  }
}`;
  }
}