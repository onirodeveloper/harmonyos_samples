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
import { textAlignTypeMapData, textOverflowTypeMapData } from '../entity/TextAreaAttributeMapping';

export class TextAreaCodeGenerator implements CommonCodeGenerator {
  private maxLines: number = 2;
  private lineSpacing: number = 5;
  private textOverflowTypeStr: string = textOverflowTypeMapData.get('Default')!.code;
  private textAlignStr: string = textAlignTypeMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'maxLines':
          this.maxLines = Number(attribute.currentValue);
          break;
        case 'lineSpacing':
          this.lineSpacing = Number(attribute.currentValue);
          break;
        case 'textOverflowType':
          this.textOverflowTypeStr =
            textOverflowTypeMapData.get(attribute.currentValue)?.code ?? textOverflowTypeMapData.get('Default')!.code;
          break;
        case 'textAlign':
          this.textAlignStr =
            textAlignTypeMapData.get(attribute.currentValue)?.code ?? textAlignTypeMapData.get('Default')!.code;
          break;
        default:
          break;
      }
    });
    return `import { LengthMetrics } from '@kit.ArkUI';

@Component
struct TextAreaComponent {
  build() {
   Column(){
    TextArea({
      text: '我有一只可爱的玩具熊。它长得很胖，胖得肚子都要爆炸了!它穿的衣服都很漂亮，而且衣服上五颜六色，有紫的、有粉的、还有黄的，非常漂亮!',
      placeholder: '请输入文字'
    })
      .margin({ left:36, right:36 })
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_L'))
      .enterKeyType(EnterKeyType.Done)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .maxLines(${this.maxLines})
      .lineSpacing(LengthMetrics.px(${this.lineSpacing}))
      .textOverflow(${this.textOverflowTypeStr})
      .textAlign(${this.textAlignStr})
     }
  }
}`;
  }
}