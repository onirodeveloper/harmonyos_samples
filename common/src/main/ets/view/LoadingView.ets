/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { BreakpointTypeEnum } from '../model/GlobalInfoModel';
import { BreakpointType } from '../util/BreakpointSystem';

@Builder
export function LoadingView(breakpoint: BreakpointTypeEnum) {
  Column() {
    Row() {
      LoadingProgress()
    }
    .width(new BreakpointType({
      sm: $r('app.float.loading_size_sm'),
      md: $r('app.float.loading_size_md'),
      lg: $r('app.float.loading_size_md'),
    }).getValue(breakpoint))
    .aspectRatio(1)

    Text($r('app.string.loading'))
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
      .margin($r('sys.float.padding_level12'))
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('sys.color.background_secondary'))
  .height('100%')
  .width('100%')
}