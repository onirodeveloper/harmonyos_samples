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

import { ColorPickerUtil } from '@ohos/common';
import type { ColorPickerAttribute } from '../viewmodel/ComponentDetailState';

/**
 * Common Hue Component
 */
@Component
export struct ColorPickerComponent {
  @ObjectLink attribute: ColorPickerAttribute;
  callback: (name: string, value: string) => void = (name: string, value: string) => {
  };

  build() {
    Column() {
      Text(this.attribute.disPlayName)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .margin({
          top: $r('sys.float.padding_level8'),
          bottom: $r('sys.float.padding_level8'),
          left: $r('sys.float.padding_level6')
        })

      Slider({
        value: ColorPickerUtil.getColorFromRgb(this.attribute.currentValue),
        style: SliderStyle.InSet,
      })
        .onChange((value: number, mode: SliderChangeMode) => {
          const curentValue: string = ColorPickerUtil.getBlockColor(value);
          if (this.attribute.currentValue !== String(curentValue)) {
            this.attribute.currentValue = curentValue;
            this.callback(this.attribute.name, curentValue);
          }
        })
        .selectedColor(Color.Transparent)
        .trackColor(new LinearGradient([
          { color: ColorPickerUtil.setRgba(255, 0, 0, 1.00), offset: 0 },
          { color: ColorPickerUtil.setRgba(255, 255, 0, 1.00), offset: 1 / 6 },
          { color: ColorPickerUtil.setRgba(0, 255, 0, 1.00), offset: 2 / 6 },
          { color: ColorPickerUtil.setRgba(8, 255, 255, 1.00), offset: 3 / 6 },
          { color: ColorPickerUtil.setRgba(0, 0, 255, 1.00), offset: 4 / 6 },
          { color: ColorPickerUtil.setRgba(255, 0, 255, 1.00), offset: 5 / 6 },
          { color: ColorPickerUtil.setRgba(255, 0, 0, 1.00), offset: 1 },
        ]))
        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
        .trackThickness($r('app.float.slider_track_thick_large'))
        .blockBorderColor(Color.White)
        .blockBorderWidth($r('app.float.slider_block_border_size'))
        .blockSize({
          width: $r('app.float.slider_block_size_large'),
          height: $r('app.float.slider_block_size_large'),
        })
        .blockColor(Color.Transparent)
        .height($r('app.float.common_component_height'))
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
  }
}