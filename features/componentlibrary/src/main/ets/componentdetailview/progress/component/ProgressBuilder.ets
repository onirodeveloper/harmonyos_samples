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
import { ProgressAttributeModifier } from '../viewmodel/ProgressAttributeModifier';
import type { ProgressDescriptor } from '../viewmodel/ProgressDescriptor';

@Builder
export function ProgressBuilder($$: DescriptorWrapper) {
  Column() {
    if (($$.descriptor as ProgressDescriptor).kind === 'Progress') {
      Progress({
        value: ($$.descriptor as ProgressDescriptor).value,
        total: DetailPageConstant.PROGRESS_MAX_VALUE,
        type: ($$.descriptor as ProgressDescriptor).type,
      })
        .height(($$.descriptor as ProgressDescriptor).type === ProgressType.Capsule ?
        DetailPageConstant.PROGRESS_CAPSULE_HEIGHT : DetailPageConstant.PROGRESS_LINE_HEIGHT)
        .attributeModifier(new ProgressAttributeModifier($$.descriptor as ProgressDescriptor))
    } else {
      LoadingProgress()
        .color(($$.descriptor as ProgressDescriptor).color)
        .size({ width: DetailPageConstant.PROGRESS_CIRCLE_WIDTH, height: DetailPageConstant.PROGRESS_CIRCLE_WIDTH })
    }
  }
  .padding($r('sys.float.padding_level16'))
  .justifyContent(FlexAlign.Center)
}