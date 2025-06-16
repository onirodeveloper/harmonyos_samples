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

import { CommonConstants } from '@ohos/common';
import { TabBarData, TABS_LIST } from '../model/TabBarModel';

@Component
export struct CustomSideBar {
  @Prop @Require currentIndex: number;
  @State focus: boolean = false;
  sideBarChange: (index: number) => void = (index: number) => {
  };

  @Builder
  BarItemBuilder(item: TabBarData) {
    Row() {
      SymbolGlyph(item.icon)
        .fontSize($r('sys.float.Title_M'))
        .fontColor(item.id === this.currentIndex ? [$r('sys.color.icon_emphasize')] :
          [$r('sys.color.icon_secondary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .symbolEffect(new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.UP), item.id === this.currentIndex)
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
      Text(item.title)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor(item.id === this.currentIndex ? $r('sys.color.interactive_active') :
        $r('sys.color.font_tertiary'))
    }
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.currentIndex !== item.id ? Color.Transparent :
      this.focus ? $r('app.color.hmos_side_bar_background_color') : $r('sys.color.interactive_hover'))
    .width('100%')
    .height($r('app.float.side_bar_height'))
    .margin({
      top: $r('sys.float.padding_level4'),
      bottom: $r('sys.float.padding_level1'),
    })
    .borderRadius($r('sys.float.corner_radius_level4'))
    .onClick(() => {
      if (this.currentIndex !== item.id) {
        this.sideBarChange(item.id);
      }
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_start_icon'))
          .width($r('app.float.app_icon_width'))
          .aspectRatio(1)
          .borderRadius($r('sys.float.corner_radius_level4'))
          .margin({ right: $r('sys.float.padding_level6') })
        Text($r('app.string.EntryAbility_label'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
      }
      .margin({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
      .height($r('app.float.side_bar_title_height'))
      .width('100%')

      ForEach(TABS_LIST, (item: TabBarData) => {
        this.BarItemBuilder(item)
      }, (item: TabBarData) => JSON.stringify(item) + this.currentIndex)
    }
    .width(CommonConstants.SIDE_BAR_WIDTH)
    .height('100%')
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .onHover((isHover: boolean) => {
      this.focus = isHover;
    })
  }
}