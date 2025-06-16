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
export struct HomePageComponent {
  build() {
    Column() {
      Text($r('app.string.homePage_title'))
        .fontSize($r('app.float.title_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
        .lineHeight($r('app.float.title_text_line_height'))
      Text($r('app.string.homePage_description'))
        .fontSize($r('app.float.description_text_font_size'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_on_secondary'))
        .lineHeight($r('app.float.description_text_line_height'))
      Image($r('app.media.hmos_image'))
        .height($r('app.float.homepage_image_height'))
    }
    .height('100%')
    .width('100%')
    .padding({
      top: $r('sys.float.padding_level12'),
    })
  }
}