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
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { RowAttributeModifier } from '../viewmodel/RowAttributeModifier';
import type { RowDescriptor } from '../viewmodel/RowDescriptor';

@Builder
export function RowBuilder($$: DescriptorWrapper) {
  Row({ space: ($$.descriptor as RowDescriptor).space }) {
    Column()
      .size({ width: $r('app.float.container_size_1'), height: $r('app.float.container_size_1') })
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .borderRadius($r('sys.float.corner_radius_level4'))
    Column()
      .size({ width: $r('app.float.container_size_2'), height: $r('app.float.container_size_2') })
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .borderRadius($r('sys.float.corner_radius_level4'))
    Column()
      .size({ width: $r('app.float.container_size_3'), height: $r('app.float.container_size_3') })
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .borderRadius($r('sys.float.corner_radius_level4'))
  }
  .width(($$.descriptor as RowDescriptor).padding === 'None' ? '80%' : 'auto')
  .height(($$.descriptor as RowDescriptor).padding === 'None' ? '50%' : 'auto')
  .padding(($$.descriptor as RowDescriptor).padding === 'Vertical' ?
    {
      top: ($$.descriptor as RowDescriptor).paddingNum,
      bottom: ($$.descriptor as RowDescriptor).paddingNum
    } : ($$.descriptor as RowDescriptor).padding === 'Horizontal' ? {
      left: ($$.descriptor as RowDescriptor).paddingNum,
      right: ($$.descriptor as RowDescriptor).paddingNum,
    } : ($$.descriptor as RowDescriptor).paddingNum)
  .attributeModifier(new RowAttributeModifier($$.descriptor as RowDescriptor))
  .borderRadius($r('sys.float.corner_radius_level6'))
  .border({ width: DetailPageConstant.CONTAINER_BORDER, color: $r('sys.color.comp_background_emphasize') })
}