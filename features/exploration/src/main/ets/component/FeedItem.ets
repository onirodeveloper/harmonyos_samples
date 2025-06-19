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

import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType } from '@ohos/common';
import type { DiscoverContent } from '../model/DiscoverData';

@Component
export struct FeedItem {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop discoverContent: DiscoverContent;

  build() {
    Column() {
      Image($rawfile(this.discoverContent.mediaUrl))
        .draggable(false)
        .borderRadius($r('sys.float.corner_radius_level4'))
        .alt($r('app.media.img_placeholder'))
        .width('100%')
        .layoutWeight(1)
      Column() {
        Text(this.discoverContent.title)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.feed_item_card_title_height'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.discoverContent.desc)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .lineHeight($r('app.float.feed_item_card_subtitle_height'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: $r('sys.float.padding_level1') })
      }
      .width('100%')
      .padding({
        left: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level2'),
      })
      .renderGroup(true)
      .margin({ top: $r('sys.float.padding_level4') })
      .alignItems(HorizontalAlign.Start)
    }
    .height(new BreakpointType({
      sm: $r('app.float.feed_item_card_height_sm'),
      md: $r('app.float.feed_item_card_height_md'),
      lg: $r('app.float.feed_item_card_height_lg'),
      xl: $r('app.float.feed_item_card_height_xl'),
    }).getValue(this.globalInfoModel.currentBreakpoint))
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4'),
      top: $r('sys.float.padding_level4'),
      bottom: $r('sys.float.padding_level8'),
    })
    .clickEffect({ level: ClickEffectLevel.HEAVY })
  }
}