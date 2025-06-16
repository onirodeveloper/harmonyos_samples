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

import type { SampleCardData, SampleContent } from '../model/SampleData';
import { TagLabel } from './TagLabel';

@Component
export struct SampleListCard {
  @Prop sampleCardData: SampleCardData;
  handleItemClick?: Function;

  build() {
    Column() {
      Text(this.sampleCardData.cardTitle)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
      Text(this.sampleCardData.cardSubTitle)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('sys.float.padding_level2') })
      ForEach(this.sampleCardData.sampleContents.slice(0, 2), (item: SampleContent, index: number) => {
        Row() {
          Column() {
            Image($rawfile(item.mediaUrl))
              .draggable(false)
              .alt($r('app.media.img_placeholder'))
              .objectFit(ImageFit.Contain)
              .height('100%')
          }
          .padding({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level2') })
          .width($r('app.float.card_img_width'))
          .backgroundColor($r('sys.color.comp_background_secondary'))

          Column() {
            Text(item.title)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            TagLabel({ tags: item.tags })
          }
          .height('100%')
          .padding($r('sys.float.padding_level8'))
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        }
        .onClick(() => this.handleItemClick?.(index, this.sampleCardData.sampleContents))
        .borderRadius($r('sys.float.corner_radius_level5'))
        .clip(true)
        .margin({ top: $r('sys.float.padding_level8') })
        .backgroundColor($r('app.color.blur_bg'))
        .width('100%')
        .height($r('app.float.card_list_height'))
      }, (item: SampleContent) => item.id.toString())
    }
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding($r('sys.float.padding_level8'))
  }
}