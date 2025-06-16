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
import { StackAttributeModifier } from '../viewmodel/StackAttributeModifier';
import type { StackDescriptor } from '../viewmodel/StackDescriptor';

@Builder
export function StackBuilder($$: DescriptorWrapper) {
  Stack() {
    Column()
      .size({ width: $r('app.float.container_size_5'), height: $r('app.float.container_size_5') })
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .borderRadius($r('sys.float.corner_radius_level4'))
    Column()
      .size({ width: $r('app.float.container_size_3'), height: $r('app.float.container_size_3') })
      .backgroundColor($r('sys.color.multi_color_03'))
      .borderRadius($r('sys.float.corner_radius_level4'))
  }
  .padding($r('sys.float.padding_level3'))
  .height($r('app.float.container_height'))
  .width($r('app.float.container_width'))
  .border({
    width: DetailPageConstant.CONTAINER_BORDER,
    color: $r('sys.color.comp_background_emphasize'),
    radius: $r('sys.float.corner_radius_level6'),
  })
  .attributeModifier(new StackAttributeModifier($$.descriptor as StackDescriptor))
}