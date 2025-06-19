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

import { LengthMetrics } from '@kit.ArkUI';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { FlexDescriptor } from '../viewmodel/FlexDescriptor';
import { ElementsNums } from '../entity/FlexAttributeMapping';

@Builder
export function FlexBuilder($$: DescriptorWrapper) {
  Flex({
    space: {
      main: LengthMetrics.vp(DetailPageConstant.FLEX_SPACE),
      cross: LengthMetrics.vp(DetailPageConstant.FLEX_SPACE),
    },
    direction: ($$.descriptor as FlexDescriptor).direction,
    wrap: ($$.descriptor as FlexDescriptor).wrap,
    justifyContent: ($$.descriptor as FlexDescriptor).justifyContent,
    alignItems: ($$.descriptor as FlexDescriptor).alignItems,
    alignContent: ($$.descriptor as FlexDescriptor).alignContent,
  }) {
    Text('1')
      .size({ width: $r('app.float.container_size_1'), height: $r('app.float.container_size_1') })
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .textAlign(TextAlign.Center)
      .border({ radius: $r('sys.float.corner_radius_level4') })
    Text('2')
      .size({ width: $r('app.float.container_size_2'), height: $r('app.float.container_size_2') })
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .textAlign(TextAlign.Center)
      .border({ radius: $r('sys.float.corner_radius_level4') })
      .alignSelf(($$.descriptor as FlexDescriptor).alignSelf)
    Text('3')
      .size({ width: $r('app.float.container_size_3'), height: $r('app.float.container_size_3') })
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .textAlign(TextAlign.Center)
      .border({ radius: $r('sys.float.corner_radius_level4') })
      .visibility(($$.descriptor as FlexDescriptor).elements === ElementsNums.FOUR ? Visibility.Visible :
      Visibility.None)
    Text('4')
      .size({ width: $r('app.float.container_size_4'), height: $r('app.float.container_size_4') })
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .textAlign(TextAlign.Center)
      .border({ radius: $r('sys.float.corner_radius_level4') })
      .visibility(($$.descriptor as FlexDescriptor).elements === ElementsNums.FOUR ? Visibility.Visible :
      Visibility.None)
  }
  .height($r('app.float.container_height'))
  .width($r('app.float.container_width'))
  .padding($r('sys.float.padding_level3'))
  .border({
    width: DetailPageConstant.CONTAINER_BORDER,
    color: $r('sys.color.comp_background_emphasize'),
    radius: $r('sys.float.corner_radius_level6'),
  })
}