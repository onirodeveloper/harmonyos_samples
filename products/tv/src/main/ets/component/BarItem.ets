/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { ColorUtil, CommonConstants, Logger } from '@ohos/common';
import { BarItemData, BarItemType } from '../model/BarItemData';

const TAG: string = '[BarItem]';

@Component
export struct BarItem {
  @Require barItemData: BarItemData;
  @Require index: number;
  @Link @Watch('updateSelectedStatus') currentIndex: number;
  @State isHover: boolean = false;
  @State isSelected: boolean = false;

  aboutToAppear(): void {
    this.updateSelectedStatus();
  }

  updateSelectedStatus() {
    this.isSelected = this.currentIndex === this.index;
  }

  build() {
    Row() {
      Button({ stateEffect: false }) {
        if (this.barItemData.barItemType === BarItemType.TEXT) {
          Text(this.barItemData.title)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontColor((this.isHover || this.isSelected) ? $r('sys.color.font_primary') :
              $r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
            .margin({
              left: $r('app.float.bar_item_text_horizontal_margin'),
              right: $r('app.float.bar_item_text_horizontal_margin'),
            })
        } else if (this.barItemData.barItemType === BarItemType.SYMBOL) {
          SymbolGlyph(this.barItemData.uri)
            .fontSize($r('app.float.bar_item_symbol_font_size'))
            .fontColor(this.isHover || this.isSelected ? [$r('sys.color.icon_primary')] :
              [$r('sys.color.icon_secondary')])
        }
      }
      .width(this.barItemData.barItemType === BarItemType.TEXT ? CommonConstants.AUTO_FIT :
        $r('app.float.bar_item_size'))
      .height($r('app.float.bar_item_size'))
      .onHover((isHover: boolean) => {
        this.isHover = isHover;
      })
      .stateStyles({
        pressed: {
          .backgroundColor(ColorUtil.getBlendColor(TAG, $r('app.color.bar_item_blend_color'),
            $r('sys.color.interactive_pressed')))
          .borderWidth($r('sys.float.border_larger'))
          .borderColor($r('app.color.bar_item_border_color'))
        },
        focused: {
          .backgroundColor(ColorUtil.getBlendColor(TAG, $r('app.color.bar_item_blend_color'),
            $r('sys.color.interactive_hover')))
          .borderWidth($r('sys.float.border_larger'))
          .borderColor($r('app.color.bar_item_border_color'))
        },
        normal: {
          .backgroundColor(this.isHover ?
            ColorUtil.getBlendColor(TAG, $r('app.color.bar_item_blend_color'), $r('sys.color.interactive_hover')) :
            this.isSelected ? $r('sys.color.comp_background_secondary') : Color.Transparent)
          .borderWidth($r('sys.float.border_larger'))
          .borderColor((this.isHover || this.isSelected) ? $r('app.color.bar_item_border_color') : Color.Transparent)
        }
      })
      .animation({
        duration: CommonConstants.BUTTON_TRANSITION_DURATION,
        curve: Curve.Sharp,
        iterations: 1,
        playMode: PlayMode.Normal
      })
      .padding({
        left: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level2'),
      })
      .onClick(() => {
        Logger.debug(TAG, `BarItem onClick ${this.index}}`);
        this.currentIndex = this.index;
      })
      .margin($r('app.float.bar_item_margin'))
    }
  }
}