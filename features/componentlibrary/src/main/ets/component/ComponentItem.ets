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

import { BreakpointTypeEnum, CommonConstants, GlobalInfoModel } from '@ohos/common';
import type { ComponentContent } from '../model/ComponentData';

@Component
export struct ComponentItem {
  @Prop componentContent: ComponentContent;
  @Prop showDivider: boolean;
  @Prop buttonColor: ResourceColor = $r('sys.color.interactive_active');
  private globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;

  build() {
    Column() {
      Divider()
        .visibility(this.showDivider ? Visibility.Visible : Visibility.Hidden)
        .color($r('sys.color.comp_background_tertiary'))
        .margin({ left: $r('sys.float.padding_level36'), right: $r('sys.float.padding_level6') })
      Row() {
        Image($rawfile(this.componentContent.mediaUrl))
          .draggable(false)
          .alt($r('app.media.ic_placeholder'))
          .borderRadius($r('sys.float.corner_radius_level5'))
          .width($r('app.float.tip_image_height'))
          .aspectRatio(1)
          .margin({ right: $r('sys.float.padding_level8') })

        Column({ space: CommonConstants.SPACE_6 }) {
          Text(this.componentContent.subTitle)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.componentContent.title)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button($r('app.string.open'), { buttonStyle: ButtonStyleMode.NORMAL, controlSize: ControlSize.SMALL })
          .borderRadius(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
          $r('sys.float.corner_radius_level4') : 0)
          .type(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? ButtonType.Normal :
          ButtonType.Capsule)
          .margin({ left: $r('sys.float.padding_level8') })
          .width($r('app.float.tip_button_width'))
          .fontColor(this.buttonColor)

      }
      .width('100%')
      .layoutWeight(1)
      .padding($r('sys.float.padding_level6'))
    }
    .renderGroup(true)
    .alignItems(HorizontalAlign.Start)
    .height($r('app.float.component_item_height'))
    .width('100%')
  }
}