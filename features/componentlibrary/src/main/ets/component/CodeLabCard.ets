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
import { ImageComponent, ProductSeriesEnum } from '@ohos/common';
import { TagTipLabel } from '@ohos/commonbusiness';
import type { ComponentCardData, ComponentContent } from '../model/ComponentData';
import { ComponentItemList, ItemSuffixType } from './ComponentItemList';

@Reusable
@Component
export struct CodeLabCard {
  @State componentCardData?: ComponentCardData = undefined;
  @State content?: ComponentContent = undefined;

  aboutToAppear(): void {
    this.content = this.componentCardData?.componentContents?.[0];
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.componentCardData = params?.componentCardData as ComponentCardData;
    this.content = this.componentCardData?.componentContents?.[0];
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      TagTipLabel({
        tags: this.content?.tagIds ?? [],
        newSymbol: $r('app.media.big_new'),
      })
        .margin({
          top: $r('sys.float.padding_level3'),
          left: $r('sys.float.padding_level3'),
        })
        .zIndex(1)

      Stack({ alignContent: Alignment.Bottom }) {
        ImageComponent({
          src: this.componentCardData?.image,
          objectFit: ImageFit.Cover,
        })
          .backgroundColor(this.componentCardData?.themeColor)
          .width('100%')
          .height('100%')
        Column() {
          Text(this.componentCardData?.title)
            .maxLines(1)
            .ellipsisMode(EllipsisMode.END)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_on_secondary'))
            .fontWeight(FontWeight.Medium)
            .lightUpEffect(1)
            .margin({
              left: $r('sys.float.padding_level6'),
              top: $r('sys.float.padding_level6'),
              bottom: $r('sys.float.padding_level2'),
            })
          Text(this.componentCardData?.subTitle)
            .maxLines(1)
            .ellipsisMode(EllipsisMode.END)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.Title_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({
              left: $r('sys.float.padding_level6'),
              bottom: $r('sys.float.padding_level2'),
            })
          ComponentItemList({
            cardContents: this.componentCardData?.componentContents ?? [],
            suffixType: ItemSuffixType.ICON,
            itemHeight: $r('app.float.codelab_content_height'),
            widthBreakpoint: WidthBreakpoint.WIDTH_SM,
          })
        }
        .renderGroup(true)
        .height($r('app.float.codelab_card_content_height'))
        .width('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .height(deviceInfo.productSeries === ProductSeriesEnum.VDE ? $r('app.float.codelab_card_height_verde') :
      $r('app.float.codelab_card_height'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
  }
}