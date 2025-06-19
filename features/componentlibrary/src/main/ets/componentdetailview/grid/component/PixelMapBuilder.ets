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

import type { ItemData } from '../entity/GridAttributeMapping';

@Builder
export function pixelMapBuilder($$: ItemData) {
  Text($$.text)
    .fontSize($r('sys.float.Body_L'))
    .size({ width: $$.width, height: $$.height })
    .fontColor($r('sys.color.icon_emphasize'))
    .textAlign(TextAlign.Center)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .borderRadius($r('sys.float.corner_radius_level4'))
    .border({ width: $r('app.float.border_width_large'), color: $r('sys.color.comp_background_emphasize') })
}