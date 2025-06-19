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
import { ImageAttributeModifier } from '../viewmodel/ImageAttributeModifier';
import type { ImageDescriptor } from '../viewmodel/ImageDescriptor';

@Builder
export function ImageBuilder($$: DescriptorWrapper) {
  Stack() {
    Image($r('app.media.image_src340'))
      .width($r('app.float.image_component_width'))
      .height((($$.descriptor as ImageDescriptor).objectFit === ImageFit.Cover ||
        ($$.descriptor as ImageDescriptor).objectFit === ImageFit.Auto) ? 'auto' :
      $r('app.float.image_component_height'))
      .colorFilter(new ColorFilter(($$.descriptor as ImageDescriptor).colorFilterMatrix))
      .attributeModifier(new ImageAttributeModifier($$.descriptor as ImageDescriptor))
      .opacity(DetailPageConstant.IMAGE_OPACITY)
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .opacity(DetailPageConstant.IMAGE_OPACITY_BG)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .backgroundColor($r('sys.color.multi_color_02'))

      Column() {
        Image($r('app.media.image_src340'))
          .colorFilter(new ColorFilter(($$.descriptor as ImageDescriptor).colorFilterMatrix))
          .attributeModifier(new ImageAttributeModifier($$.descriptor as ImageDescriptor))
      }
      .borderRadius($r('sys.float.corner_radius_level8'))
      .clip(($$.descriptor as ImageDescriptor).clip)
    }
    .width($r('app.float.image_component_width'))
    .height($r('app.float.image_component_height'))
  }
}