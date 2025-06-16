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

import type { SliderComAttribute } from '../viewmodel/ComponentDetailState';

/**
 * Slider public component
 */
@Component
export struct SliderComponent {
  @ObjectLink attribute: SliderComAttribute;
  callback: (name: string, value: string, mode?: SliderChangeMode) => void = (name: string, value: string) => {
  };

  build() {
    Column() {
      Row() {
        Text(this.attribute.disPlayName)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
        Blank()
        Text(this.attribute.currentValue)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .padding({ right: $r('sys.float.padding_level2') })
      }
      .height($r('app.float.common_component_height'))
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: $r('sys.float.padding_level1') })
      .width('100%')
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })

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
          .selectedColor($r('sys.color.icon_emphasize'))
          .trackThickness($r('app.float.common_component_track_thickness'))
          .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
          .width('100%')
      }
      .height($r('app.float.common_component_height'))
      .width('100%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}