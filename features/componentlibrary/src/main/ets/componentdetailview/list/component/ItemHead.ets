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

import { CommonConstants } from '@ohos/common';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';

@Builder
export function itemHead(text: string, $$: DescriptorWrapper) {
  Row() {
    Text(text)
      .textAlign(TextAlign.Center)
      .fontSize($r('sys.float.Body_L'))
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .fontColor($r('sys.color.font_on_primary'))
      .width('100%')
      .height($r('app.float.text_height_large'))
      .margin({ bottom: $r('sys.float.padding_level4') })
  }
  .margin({ left: -CommonConstants.SPACE_8, right: -CommonConstants.SPACE_8 })
}