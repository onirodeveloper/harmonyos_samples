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

import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, BreakpointTypeEnum, CommonConstants } from '@ohos/common';
import { FullScreenNavigationData } from '../model/FullScreenNavigationData';

@Component
export struct FullScreenNavigation {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop topNavigationData: FullScreenNavigationData = new FullScreenNavigationData();
  @StorageProp('BlurRenderGroup') blurRenderGroup: boolean = false;
  @BuilderParam tabView?: () => void;

  build() {
    Column() {
      Row() {
        Text(this.topNavigationData.title)
          .scale({
            x: this.topNavigationData.titleScale,
            y: this.topNavigationData.titleScale,
            z: this.topNavigationData.titleScale,
            centerX: 0,
            centerY: 0,
          })
          .fontSize(new BreakpointType({
            sm: $r('sys.float.Title_M'),
            md: $r('sys.float.Title_L'),
            lg: $r('sys.float.Title_L'),
            xl: $r('sys.float.Title_S'),
          }).getValue(this.globalInfoModel.currentBreakpoint))
          .fontColor(this.topNavigationData.titleColor)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .layoutWeight(1)
      }
      .margin({ top: this.topNavigationData.titleOffsetY })
      .alignItems(VerticalAlign.Center)
      .height(CommonConstants.NAVIGATION_HEIGHT)
      .padding({
        left: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.globalInfoModel.currentBreakpoint),
        right: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.globalInfoModel.currentBreakpoint),
      })

      if (this.tabView && this.topNavigationData.showTab) {
        this.tabView()
      }
      Divider()
        .color($r('sys.color.comp_divider'))
        .visibility(this.topNavigationData.isBlur ? Visibility.Visible : Visibility.Hidden)
    }
    .backgroundBlurStyle(this.topNavigationData.isBlur ? BlurStyle.COMPONENT_THICK : undefined)
    .backgroundColor(Color.Transparent)
    .renderGroup(this.blurRenderGroup)
    .padding({
      top: this.globalInfoModel.statusBarHeight,
      left: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ? CommonConstants.TAB_BAR_WIDTH : 0,
    })
    .width('100%')
  }
}