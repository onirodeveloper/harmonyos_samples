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

import { deviceInfo } from '@kit.BasicServicesKit';
import { ProductSeriesEnum } from '@ohos/common';
import type { ComponentCardData, ComponentContent } from '../model/ComponentData';

@Reusable
@Component
export struct CodeLabCard {
  @State componentCardData?: ComponentCardData = undefined;
  @State content?: ComponentContent = undefined;

  aboutToAppear(): void {
    this.content = this.componentCardData?.cardContents[0];
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.componentCardData = params.componentCardData as ComponentCardData;
    this.content = this.componentCardData.cardContents[0];
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image($rawfile(this.componentCardData?.cardImage))
        .alt($r('app.media.ic_placeholder'))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
      Column() {
        Text(this.componentCardData?.cardTitle)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_on_secondary'))
          .fontWeight(FontWeight.Medium)
          .lightUpEffect(1)
          .margin({
            left: $r('sys.float.padding_level6'),
            top: $r('sys.float.padding_level6'),
            bottom: $r('sys.float.padding_level2'),
          })
        Text(this.componentCardData?.cardSubTitle)
          .fontSize($r('sys.float.Title_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: $r('sys.float.padding_level6'), bottom: $r('sys.float.padding_level2') })
        Row() {
          Image($rawfile(this.content?.mediaUrl))
            .draggable(false)
            .width($r('app.float.tip_image_height'))
            .borderRadius($r('sys.float.corner_radius_level5'))
            .aspectRatio(1)
          Column() {
            Text(this.content?.subTitle)
              .fontSize($r('sys.float.Subtitle_M'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: $r('sys.float.padding_level4') })
            Text(this.content?.title)
              .fontSize($r('sys.float.Body_S'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('sys.color.font_on_primary'))
              .maxLines(1)
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level8') })
          .layoutWeight(1)

          Button() {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_secondary')])
              .fontSize($r('sys.float.Title_M'))
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .width($r('app.float.card_button_height'))
          .aspectRatio(1)
        }
        .padding($r('sys.float.padding_level6'))
        .width('100%')
        .height($r('app.float.codelab_content_height'))
        .backgroundColor($r('sys.color.comp_background_secondary'))
      }
      .renderGroup(true)
      .height($r('app.float.card_content_height'))
      .width('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(deviceInfo.productSeries === ProductSeriesEnum.VDE ? $r('app.float.codelab_card_height_verde') : $r('app.float.codelab_card_height'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
  }
}