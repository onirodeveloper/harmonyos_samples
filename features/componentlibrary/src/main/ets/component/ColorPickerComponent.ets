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

import { ColorPickerUtil, HmosListItem } from '@ohos/common';
import type { ColorPickerAttribute } from '../viewmodel/ComponentDetailState';

const SLIDER_MAX_VALUE: number = 100;

/**
 * Common Hue Component
 */
@Component
export struct ColorPickerComponent {
  @ObjectLink attribute: ColorPickerAttribute;
  @State curVal: number = 0;
  callback: (name: string, value: string, mode?: SliderChangeMode) => void = (_name: string, _value: string) => {
  };

  build() {
    Column() {
      HmosListItem({
        title: this.attribute.displayName,
        desc: ' ',
      })

      Slider({
        value: this.curVal === SLIDER_MAX_VALUE ? this.curVal :
          ColorPickerUtil.getColorFromRgb(this.attribute.currentValue),
        style: SliderStyle.InSet,
      })
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode === SliderChangeMode.Moving || mode === SliderChangeMode.Click) {
            this.curVal = value;
            const curentValue: string = ColorPickerUtil.getBlockColor(value);
            if (this.attribute.currentValue !== String(curentValue)) {
              this.attribute.currentValue = curentValue;
              this.callback(this.attribute.name, curentValue, mode);
            }
          }
        })
        .selectedColor(Color.Transparent)
        .trackColor(new LinearGradient([
          { color: ColorPickerUtil.setRgba(255, 0, 0, 1.00), offset: 0 },
          { color: ColorPickerUtil.setRgba(255, 255, 0, 1.00), offset: ColorPickerUtil.COLOR_SEGMENT_1 },
          { color: ColorPickerUtil.setRgba(0, 255, 0, 1.00), offset: ColorPickerUtil.COLOR_SEGMENT_2 },
          { color: ColorPickerUtil.setRgba(0, 255, 255, 1.00), offset: ColorPickerUtil.COLOR_SEGMENT_3 },
          { color: ColorPickerUtil.setRgba(0, 0, 255, 1.00), offset: ColorPickerUtil.COLOR_SEGMENT_4 },
          { color: ColorPickerUtil.setRgba(255, 0, 255, 1.00), offset: ColorPickerUtil.COLOR_SEGMENT_5 },
          { color: ColorPickerUtil.setRgba(255, 0, 0, 1.00), offset: ColorPickerUtil.COLOR_SEGMENT_6 },
        ]))
        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK)
        .trackThickness($r('app.float.slider_track_thick_large'))
        .blockBorderColor(Color.White)
        .blockBorderWidth($r('app.float.slider_block_border_size'))
        .blockSize({
          width: $r('app.float.slider_block_size_large'),
          height: $r('app.float.slider_block_size_large'),
        })
        .padding({
          left: $r('sys.float.padding_level2'),
          right: $r('sys.float.padding_level2'),
        })
        .blockColor(Color.Transparent)
        .height($r('app.float.common_component_height'))
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
    })
  }
}