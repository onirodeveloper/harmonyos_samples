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

import { CommonConstants, ImageUtil } from '@ohos/common';
import type { SampleCardData, SampleContent } from '../model/SampleData';
import { TagLabel } from './TagLabel';

@Component
export struct PictureCard {
  @Prop sampleCardData: SampleCardData;
  @State bgTopColor: string = '';
  @State bgBottomColor: string = '';
  @State sampleContent?: SampleContent = undefined;

  aboutToAppear(): void {
    this.sampleContent = this.sampleCardData.sampleContents[0];
    ImageUtil.getColorFromImgUrl(this.sampleContent.mediaUrl, true).then((colorArr: number[]) => {
      this.bgTopColor = `rgba(${colorArr[0]},${colorArr[1]},${colorArr[2]},0)`;
      this.bgBottomColor = `rgba(${colorArr[0]},${colorArr[1]},${colorArr[2]},1)`;
    });
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image($rawfile(this.sampleCardData.cardImage))
          .draggable(false)
          .linearGradientBlur(60,
            {
              fractionStops: [[0, 0], [0, 0.64], [1, 0.82], [1, 1]],
              direction: GradientDirection.Bottom,
            })
          .alt($r('app.media.img_placeholder'))
          .height('100%')
          .width('100%')
        Row() {
          Column() {
            Text(this.sampleContent?.subTitle)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_on_secondary'))
              .fontWeight(FontWeight.Medium)
              .lightUpEffect(1)
              .margin({ bottom: $r('sys.float.padding_level4') })
            Text(this.sampleContent?.title)
              .fontSize($r('sys.float.Title_M'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: $r('sys.float.padding_level6') })
            TagLabel({ tags: this.sampleContent?.tags || [], isDark: true })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_on_primary')])
              .fontSize($r('sys.float.Title_M'))
          }
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width($r('app.float.card_button_height'))
          .aspectRatio(1)
        }
        .linearGradient({
          angle: CommonConstants.LINEAR_GRADIENT_ANGLE,
          colors: [[this.bgTopColor, 0], [this.bgBottomColor, 0.75], [this.bgBottomColor, 1]]
        })
        .height($r('app.float.card_content_height'))
        .padding($r('sys.float.padding_level8'))
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .height($r('app.float.picture_card_height'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .clip(true)
    }
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .clip(true)
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}