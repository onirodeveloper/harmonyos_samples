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
export function ToggleBuilder($$: DescriptorWrapper) {
  Row() {
    if (($$.descriptor as ToggleDescriptor).toggleType === ToggleType.Switch) {
      Text($r('app.string.toggle_type'))
        .fontSize($r('app.float.default_font_16'))
        .fontColor($r('sys.color.font_secondary'))
      Blank()
    }
    Toggle({
      type: ($$.descriptor as ToggleDescriptor).toggleType,
      isOn: ($$.descriptor as ToggleDescriptor).isOn
    }) {
      Text($r('app.string.toggle_button_text'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('app.float.default_font_12'))
        .visibility(($$.descriptor as ToggleDescriptor).toggleType === ToggleType.Button ? Visibility.Visible :
        Visibility.Hidden)
    }
    .onChange((isOn: boolean) => {
      ComponentDetailManager.getInstance().getDetailViewModel('Toggle')?.sendEvent(
        new ComPreviewChangeEvent('isOn', String(isOn))
      )
    })
    .width(($$.descriptor as ToggleDescriptor).toggleType === ToggleType.Button ? DetailPageConstant.TOGGLE_WIDTH :
      undefined)
    .height(($$.descriptor as ToggleDescriptor).toggleType === ToggleType.Button ? DetailPageConstant.TOGGLE_HEIGHT :
      undefined)
    .selectedColor(($$.descriptor as ToggleDescriptor).backgroundColor)
  }
  .width('100%')
  .justifyContent(FlexAlign.Center)
  .padding({ left: $r('sys.float.padding_level16'), right: $r('sys.float.padding_level16') })
}