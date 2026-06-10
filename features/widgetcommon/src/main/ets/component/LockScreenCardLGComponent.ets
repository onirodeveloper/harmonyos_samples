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
export struct LockScreenCardLGComponent {
  handleClickAction?: Function;

  build() {
    Row() {
      Column() {
        Text($r('app.string.lock_screen_title'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_primary'))
          .margin({ bottom: $r('sys.float.padding_level1') })
        Text($r('app.string.lock_screen_subtitle'))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .opacity(0.8)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Image($r('app.media.ic_lock_screen'))
        .width($r('app.float.lock_screen_icon_size'))
        .aspectRatio(1)
        .margin({ left: $r('sys.float.padding_level4') })
    }
    .onClick(() => {
      this.handleClickAction?.();
    })
    .width('100%')
    .height('100%')
    .padding({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6'),
    })
  }
}