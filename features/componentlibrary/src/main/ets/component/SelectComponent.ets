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

import type { SelectComAttribute } from '../viewmodel/ComponentDetailState';
import { SelectMenuAttributeModifier } from './SelectMenuAttributeModifier';

/**
 * Dropdown selection public component
 */
@Component
export struct SelectComponent {
  @ObjectLink attribute: SelectComAttribute;
  @State currentIndex: number = 0;
  callback: (name: string, value: string) => void = (name: string, value: string) => {
  };

  aboutToAppear(): void {
    this.attribute.selectOption.forEach((element, index) => {
      if (element.value.toString() === this.attribute.currentValue) {
        this.currentIndex = index;
      }
    });
  }

  build() {
    Row() {
      Text(this.attribute.disPlayName)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
      Blank()
      Select(this.attribute.selectOption)
        .id('select')
        .selected(this.currentIndex)
        .value(this.attribute.currentValue)
        .font({ size: $r('sys.float.Body_M'), weight: FontWeight.Regular })
        .fontColor($r('sys.color.font_secondary'))
        .optionFont({ size: $r('sys.float.Subtitle_M'), weight: FontWeight.Medium })
        .optionFontColor($r('sys.color.font_primary'))
        .optionWidth($r('app.float.detail_common_component_option_width'))
        .menuAlign(MenuAlignType.END, { dx: 0, dy: 0 } as Offset)
        .menuItemContentModifier(new SelectMenuAttributeModifier())
        .menuBackgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
        .optionBgColor(Color.White)
        .onSelect((_index: number, value: string) => {
          if (this.attribute.currentValue !== value) {
            this.currentIndex = _index;
            this.attribute.currentValue = value;
            this.callback(this.attribute.name, value);
          }
        })
    }
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    .height($r('app.float.common_component_height'))
    .width('100%')
  }
}