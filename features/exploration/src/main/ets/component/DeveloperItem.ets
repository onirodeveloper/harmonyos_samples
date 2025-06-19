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

import type { DiscoverContent } from '../model/DiscoverData';

@Component
export struct DeveloperItem {
  @Prop discoverContent: DiscoverContent;


  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image($rawfile(this.discoverContent.mediaUrl))
        .draggable(false)
        .alt($r('app.media.img_placeholder'))
        .width('100%')
        .height('100%')
      Column() {
        Row() {
          Text(this.discoverContent.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Bold)
          Text(this.discoverContent.subTitle)
            .margin({ bottom: $r('sys.float.padding_level1') })
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Regular)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)
        .width('100%')

        Text(this.discoverContent.desc)
          .margin({ top: $r('sys.float.padding_level2') })
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(FontWeight.Regular)
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.blur_bg'))
      .renderGroup(true)
      .padding({
        top: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8'),
      })
    }
    .clickEffect({ level: ClickEffectLevel.HEAVY })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}