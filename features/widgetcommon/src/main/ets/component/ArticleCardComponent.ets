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

import { CardListParameter } from '../viewmodel/CardListParameter';
import { ArticleListItem } from '../model/FormCardInfo';

@Component
export struct ArticleCardComponent {
  @Link cardList: ArticleListItem[];
  private readonly orderImageArray: Resource[] = [
    $r('app.media.first_order'),
    $r('app.media.second_order'),
    $r('app.media.third_order'),
  ];
  onClickProcess: (item?: ArticleListItem) => void = () => {
  };
  @State cardListParameter: CardListParameter = {
    backgroundColor: $r('sys.color.ohos_id_color_background'),
    title: $r('app.string.widget_display_name'),
    backgroundImage: $r('app.media.list_card_bg'),
    backgroundImageSize: ImageSize.Cover,
    titleColor: $r('app.color.article_card_icon_emphasize'),
    logo: $r('app.media.list_card_logo'),
    subTitle: $r('app.string.card_list_subtitle'),
    subTitleColor: $r('app.color.article_card_font_secondary'),
    rightArrowIcon: $r('sys.symbol.chevron_right')
  };

  @Builder
  cardListBuilder() {
    Column() {
      ForEach(this.cardList, (item: ArticleListItem, index: number) => {
        Row() {
          Row() {
            Image(index < this.orderImageArray.length ? this.orderImageArray[index] : undefined)
              .width($r('app.float.order_image_size'))
              .objectFit(ImageFit.Cover)
            Text(item.title)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.article_card_font_primary'))
              .margin({
                left: $r('sys.float.padding_level4'),
                right: $r('sys.float.padding_level4'),
              })
          }

          Text(item.name)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('app.color.article_card_font_secondary'))
            .margin({ left: $r('sys.float.padding_level2') })
        }
        .width('80%')
        .alignItems(VerticalAlign.Center)
        .flexGrow(1)
        .onClick(() => this.onClickProcess(item))
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .layoutWeight(1)
    .padding({
      top: $r('sys.float.padding_level5'),
      bottom: $r('sys.float.padding_level5'),
    })
  }

  build() {
    if (this.cardListParameter !== undefined) {
      Column() {
        Row() {
          Row() {
            Image(this.cardListParameter.logo)
              .width($r('app.float.list_logo_size_sm'))
              .aspectRatio(1)
            Text(this.cardListParameter.title)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Bold)
              .fontColor(this.cardListParameter.titleColor)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('sys.float.padding_level2') })
          }

          Blank()
          if (this.cardListParameter.subTitle) {
            Row() {
              Text(this.cardListParameter.subTitle)
                .fontSize($r('sys.float.Body_S'))
                .fontColor(this.cardListParameter.subTitleColor)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              SymbolGlyph(this.cardListParameter.rightArrowIcon)
                .fontColor([$r('app.color.article_card_font_secondary')])
                .fontSize($r('sys.float.Body_M'))
            }
            .onClick(() => this.onClickProcess())
          }
        }
        .margin({
          top: $r('sys.float.padding_level6')
        })
        .width('100%')

        this.cardListBuilder()
      }
      .backgroundImage(this.cardListParameter.backgroundImage)
      .backgroundImageSize(this.cardListParameter.backgroundImageSize)
      .backgroundColor(this.cardListParameter.backgroundColor)
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      })
    }
  }
}