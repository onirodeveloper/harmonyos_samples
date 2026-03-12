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
import { FormCardConstants } from '../constants/FormCardConstants';

@Component
export struct CardListComponent {
  @BuilderParam customBuilderParam: () => void = this.customBuilder;
  @Link cardListParameter: CardListParameter;
  onClickProcess: () => void = () => {
  };

  @Builder
  customBuilder() {
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
        .width(FormCardConstants.FULL_PERCENT)

        this.customBuilderParam()
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