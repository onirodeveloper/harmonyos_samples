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

import { HmosListItem } from '@ohos/common';
import type { SliderComAttribute } from '../viewmodel/ComponentDetailState';

/**
 * Slider public component
 */
@Component
export struct SliderComponent {
  @ObjectLink attribute: SliderComAttribute;
  callback: (name: string, value: string, mode?: SliderChangeMode) => void =
    (_name: string, _value: string, _mode?: SliderChangeMode) => {
    };

  build() {
    Column() {
      HmosListItem({
        title: this.attribute.displayName,
        desc: this.attribute.currentValue,
      })

      Row() {
        Slider({
          value: Number(this.attribute.currentValue),
          min: this.attribute.leftRange,
          max: this.attribute.rightRange,
          style: SliderStyle.OutSet,
          step: this.attribute.step,
        })
          .onChange((value: number, mode: SliderChangeMode) => {
            if (this.attribute.currentValue !== String(value)) {
              this.attribute.currentValue = String(value);
              this.callback(this.attribute.name, String(value), mode);
            }
          })
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .blockSize({
            width: $r('app.float.common_component_block_size'),
            height: $r('app.float.common_component_block_size'),
          })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .trackThickness($r('app.float.common_component_track_thickness'))
          .width('100%')
      }
      .padding({
        left: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level2'),
      })
      .height($r('app.float.common_component_height'))
      .width('100%')
    }
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}