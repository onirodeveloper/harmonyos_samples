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

import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { ComponentDetailManager } from '../../../viewmodel/ComponentDetailManager';
import { ComPreviewChangeEvent } from '../../../viewmodel/ComponentDetailPageVM';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { ToggleDescriptor } from '../viewmodel/ToggleDescriptor';

@Builder
export function ToggleComponentBuilder(descriptorWrapper: DescriptorWrapper) {
  Toggle({
    type: (descriptorWrapper.descriptor as ToggleDescriptor).toggleType,
    isOn: (descriptorWrapper.descriptor as ToggleDescriptor).isOn
  })
    .selectedColor((descriptorWrapper.descriptor as ToggleDescriptor).backgroundColor)
    .onChange((isOn: boolean) => {
      ComponentDetailManager.getInstance().getDetailViewModel('Toggle')?.sendEvent(
        new ComPreviewChangeEvent('isOn', String(isOn))
      )
    })
}

@Builder
export function ToggleBuilder(descriptorWrapper: DescriptorWrapper) {
  Row() {
    if ((descriptorWrapper.descriptor as ToggleDescriptor).toggleType === ToggleType.Switch) {
      Text($r('app.string.toggle_type'))
        .fontSize($r('app.float.default_font_16'))
        .fontColor($r('sys.color.font_secondary'))
      Blank()
      ToggleComponentBuilder(descriptorWrapper)
    } else if ((descriptorWrapper.descriptor as ToggleDescriptor).toggleType === ToggleType.Button) {
      Toggle({
        type: (descriptorWrapper.descriptor as ToggleDescriptor).toggleType,
        isOn: (descriptorWrapper.descriptor as ToggleDescriptor).isOn
      }) {
        Text($r('app.string.toggle_button_text'))
          .fontColor((descriptorWrapper.descriptor as ToggleDescriptor).isOn ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_primary'))
          .fontSize($r('app.float.default_font_12'))
      }
      .width(DetailPageConstant.TOGGLE_WIDTH)
      .height(DetailPageConstant.TOGGLE_HEIGHT)
      .selectedColor((descriptorWrapper.descriptor as ToggleDescriptor).backgroundColor)
      .onChange((isOn: boolean) => {
        ComponentDetailManager.getInstance().getDetailViewModel('Toggle')?.sendEvent(
          new ComPreviewChangeEvent('isOn', String(isOn))
        )
      })
    } else {
      ToggleComponentBuilder(descriptorWrapper)
    }
  }
  .width('100%')
  .justifyContent(FlexAlign.Center)
  .padding({
    left: $r('sys.float.padding_level16'),
    right: $r('sys.float.padding_level16'),
  })
}