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
import { ArcScrollBar } from '@ohos.arkui.ArcScrollBar';

const MAX_LINES = 3;
const TITLE_MAX_WIDTH = 129;

@Component
export struct QRCodeComponent {
  webviewUrl: string = '';
  title: string = '';
  private scroller: Scroller = new Scroller();
  private singleLine: boolean = false;

  aboutToAppear(): void {
    const textSize = this.getUIContext().getMeasureUtils().measureTextSize({
      textContent: this.title,
      fontSize: $r('sys.float.Title_L'),
      fontWeight: FontWeight.Bold
    });
    this.singleLine = this.getUIContext().px2vp(textSize.width as number) < TITLE_MAX_WIDTH;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll(this.scroller) {
        Column() {
          Text(this.title)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(MAX_LINES)
            .maxFontSize($r('sys.float.Title_L'))
            .minFontSize($r('app.float.title_min_font_size'))
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MAX_LINES_FIRST)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(FontWeight.Bold)
            .wordBreak(WordBreak.HYPHENATION)
            .width('100%')
            .height(this.singleLine ? $r('app.float.single_line_height') : $r('app.float.double_line_height'))
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .padding({
              left: $r('app.float.qrcode_padding'),
              right: $r('app.float.qrcode_padding'),
            })
            .margin({
              top: $r('sys.float.padding_level8')
            })

          Column() {
            QRCode(this.webviewUrl)
              .enabled(false)
              .height('100%')
              .width('100%')
              .borderRadius($r('sys.float.corner_radius_level6'))
              .padding($r('sys.float.padding_level6'))
          }
          .width($r('app.float.qrcode_size'))
          .height($r('app.float.qrcode_size'))
          .margin({
            top: $r('app.float.qrcode_margin_top'),
            bottom: $r('sys.float.padding_level2')
          })

          Text($r('app.string.qrcode_base'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .margin({ bottom: $r('app.float.qrcode_text_margin_bottom') })
            .focusable(true)
            .defaultFocus(true)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .padding({
        left: $r('app.float.qrcode_padding'),
        right: $r('app.float.qrcode_padding'),
      })

      ArcScrollBar({ scroller: this.scroller, state: BarState.Auto })
    }
    .height('100%')
    .width('100%')
  }
}