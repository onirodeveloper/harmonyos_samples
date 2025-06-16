/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apach License, Version 2.0 (the "License");
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

import { LengthMetrics } from '@kit.ArkUI';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { StyleTextDescriptor } from '../viewmodel/StyleTextDescriptor';

@Builder
export function StyleTextBuilder($$: DescriptorWrapper) {
  StyleTextComponent({ styleTextDescriptor: $$.descriptor as StyleTextDescriptor })
}

@Component
struct StyleTextComponent {
  @Prop @Watch('onStyleUpdated') styleTextDescriptor: StyleTextDescriptor;
  private text: string =
    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  textController: TextController = new TextController();
  paragraphStyleAttr: ParagraphStyle = new ParagraphStyle({
    textIndent: LengthMetrics.vp(this.styleTextDescriptor.textIndent),
    maxLines: this.styleTextDescriptor.maxLines
  });
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
            fontColor: this.styleTextDescriptor.highlightColor
          })
        }
      ]);

  build() {
    Column() {
      Text(undefined, { controller: this.textController })
        .margin({ left: $r('app.float.common_left_right_margin'), right: $r('app.float.common_left_right_margin') })
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
    }
    .width($r('app.float.multiline_text_width'))
    .justifyContent(FlexAlign.Center)
    .onAttach(() => {
      this.textController.setStyledString(this.mutableStyledString);
    })
  }

  onStyleUpdated(_changedPropertyName: string) {
    this.mutableStyledString.setStyle({
      start: 0,
      length: 3,
      styledKey: StyledStringKey.PARAGRAPH_STYLE,
      styledValue: new ParagraphStyle({
        textIndent: LengthMetrics.vp(this.styleTextDescriptor.textIndent),
        maxLines: this.styleTextDescriptor.maxLines,
        overflow: this.styleTextDescriptor.overflow,
      }),
    });
    this.mutableStyledString.setStyle({
      start: 10,
      length: 5,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: this.styleTextDescriptor.highlightColor,
      }),
    });
    this.textController.setStyledString(this.mutableStyledString);
  }
}