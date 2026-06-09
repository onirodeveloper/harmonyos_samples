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

@Component
export struct WidgetCardComponent {
  build() {
    Stack() {
      Image($r('app.media.ic_widget'))
        .width('100%')
        .height('100%')
      Column() {
        Text($r('app.string.widget_display_name'))
          .fontSize($r('sys.float.Subtitle_M'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
        Text($r('app.string.detail_immersive'))
          .fontSize($r('sys.float.Body_S'))
          .margin({ top: $r('sys.float.padding_level1') })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_on_secondary'))
          .fontWeight(FontWeight.Regular)
          .maxLines(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding($r('sys.float.padding_level6'))
    }
    .width('100%')
    .height('100%')
  }
}