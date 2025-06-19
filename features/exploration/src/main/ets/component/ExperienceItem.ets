/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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
import type { DiscoverContent } from '../model/DiscoverData';

@Component
export struct ExperienceItem {
  @Prop discoverContent: DiscoverContent;
  @State bgTopColor: string = '';
  @State bgBottomColor: string = '';

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image($rawfile(this.discoverContent.mediaUrl))
        .alt($r('app.media.img_placeholder'))
        .objectFit(ImageFit.Cover)
        .draggable(false)
        .width('100%')
        .height('100%')
      Column() {
        Text(this.discoverContent.subTitle)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
        Text(this.discoverContent.title)
          .margin({ top: $r('sys.float.padding_level3'), bottom: $r('sys.float.padding_level2') })
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
        Text(this.discoverContent.desc)
          .fontColor($r('sys.color.font_on_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
      }
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8'),
        top: $r('sys.float.padding_level6'),
      })
      .height($r('app.float.img_card_content_height'))
      .width('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
    }
    .clickEffect({ level: ClickEffectLevel.HEAVY })
    .height(deviceInfo.productSeries === ProductSeriesEnum.VDE ? $r('app.float.img_card_height_verde') :
    $r('app.float.img_card_height'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
  }
}