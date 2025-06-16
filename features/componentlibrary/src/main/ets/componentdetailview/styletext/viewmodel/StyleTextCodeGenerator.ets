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
import { textOverflowTypeMapData } from '../../textarea/entity/TextAreaAttributeMapping';

export class StyleTextCodeGenerator implements CommonCodeGenerator {
  private textIndent: number = 0;
  private maxLines: number = 2;
  private overflowStr: string = textOverflowTypeMapData.get('Default')!.code;
  private highlightColor: string = highlightColorMap.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'textIndent':
          this.textIndent = Number(attribute.currentValue) as number;
          break;
        case 'maxLines':
          this.maxLines = Number(attribute.currentValue) as number;
          break;
        case 'overflow':
          this.overflowStr =
            textOverflowTypeMapData.get(attribute.currentValue)?.code ?? textOverflowTypeMapData.get('Default')!.code;
          break;
        case 'highlightColor':
          this.highlightColor = attribute.currentValue;
          break;
        default:
          break;
      }
    });

    return `import { LengthMetrics } from '@kit.ArkUI';

@Component
struct StyleTextComponent {
  private text: string =
    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  textController: TextController = new TextController();
  paragraphStyleAttr: ParagraphStyle = new ParagraphStyle({
    textIndent: LengthMetrics.vp(${this.textIndent}),
    maxLines: ${this.maxLines},
    overflow: ${this.overflowStr}
  });
  textIndentStyle: SpanStyle = {
    start: 0,
    length: 3,
    styledKey: StyledStringKey.PARAGRAPH_STYLE,
    styledValue: this.paragraphStyleAttr
  };
  mutableStyledString: MutableStyledString =
    new MutableStyledString(this.text,
      [
        {
          start: 0,
          length: 3,
          styledKey: StyledStringKey.PARAGRAPH_STYLE,
          styledValue: this.paragraphStyleAttr
        },
        {
          start: 10,
          length: 5,
          styledKey: StyledStringKey.FONT,
          styledValue: new TextStyle({
            fontColor: '${this.highlightColor}'
          })
        }
      ]);

  build() {
    Column() {
      Text(undefined, { controller: this.textController }) {
      }
      .margin({ left: 36, right: 36 })
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Regular)
    }
    .width(320)
    .justifyContent(FlexAlign.Center)
    .onAttach(() => {
      this.textController.setStyledString(this.mutableStyledString);
    })
  }
 }`;
  }
}