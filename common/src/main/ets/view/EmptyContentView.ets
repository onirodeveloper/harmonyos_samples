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

import { CommonConstants } from '../constant/CommonConstants';

@Builder
export function EmptyContentView(imgSrc: Resource, description: ResourceStr) {
  Column({ space: CommonConstants.SPACE_8 }) {
    Image(imgSrc)
      .draggable(false)
      .size({ width: $r('app.float.empty_content_image_size'), height: $r('app.float.empty_content_image_size') })
    Text(description)
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontSize($r('sys.float.Body_M'))
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('sys.color.background_secondary'))
  .width('100%')
  .layoutWeight(1)
}