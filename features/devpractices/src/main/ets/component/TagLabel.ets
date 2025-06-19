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

import { MeasureText } from '@kit.ArkUI';
import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointTypeEnum, CommonConstants } from '@ohos/common';
import { CardStyleTypeEnum } from '@ohos/commonbusiness';
import { SampleDetailConstant } from '../constant/CommonConstants';

interface TagInfo {
  tag: string;
  width: number;
}

const PADDING_WIDTH: number = 24;
const MIN_WIDTH: number = 42;
const ELLIPSIS = '...';

@Component
export struct TagLabel {
  @Prop tags: string[];
  @Prop @Watch('changeTagList') maxWidth: number;
  @Prop isDark: boolean;
  @Prop cardStyleType: CardStyleTypeEnum;
  @State tagList: TagInfo[] = [];
  @State showEllipsis: boolean = false;
  @State globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @State displayPopup: boolean = false;
  private allTagStr: string = '';

  aboutToAppear(): void {
    this.changeTagList();
  }

  changeTagList() {
    const tempList: TagInfo[] = [];
    let currentWidth: number = 0;
    const ellipsisWidth = this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? MIN_WIDTH : 0;
    this.tags.forEach((tag: string) => {
      const tagWidth: number = Math.ceil(px2vp(MeasureText.measureText({
        textContent: tag,
        fontSize: $r('sys.float.Body_S')
      }))) + PADDING_WIDTH + CommonConstants.SPACE_8;
      if (!this.maxWidth || currentWidth + tagWidth < this.maxWidth) {
        currentWidth += tagWidth;
        tempList.push({ tag: tag, width: tagWidth - CommonConstants.SPACE_8 });
      } else if (currentWidth < this.maxWidth - ellipsisWidth) {
        const hideEllipse: boolean = this.globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL ||
          (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL &&
            tempList.length === 0)
        const width: number = this.maxWidth - currentWidth - CommonConstants.SPACE_8;
        if (hideEllipse) {
          this.showEllipsis = false;
        } else {
          this.showEllipsis = true;
        }
        if (width > MIN_WIDTH && hideEllipse) {
          tempList.push({ tag, width });
        }
        currentWidth = this.maxWidth;
      }
    });
    this.tagList = tempList;
    if (this.tags.length > 0) {
      this.allTagStr = this.tags.join(';');
    }
  }

  build() {
    Row({ space: CommonConstants.SPACE_8 }) {
      ForEach(this.tagList, (item: TagInfo) => {
        Row() {
          Text(item.tag)
            .fontColor(this.cardStyleType === CardStyleTypeEnum.PICTURE_TO_SWIPER ?
            $r('app.color.card_font_secondary_color') : $r('sys.color.font_secondary'))
            .width(item.width - PADDING_WIDTH)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
        }
        .justifyContent(FlexAlign.Center)
        .borderRadius('50%')
        .padding({
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2'),
        })
        .width(item.width)
        .backgroundColor(this.isDark ? $r('sys.color.icon_on_tertiary') :
        $r('sys.color.comp_background_tertiary'))
      }, (item: TagInfo) => item.tag)
      if (this.showEllipsis) {
        Row() {
          Text(ELLIPSIS)
            .fontColor(this.isDark ? $r('sys.color.font_on_secondary') : $r('sys.color.font_secondary'))
            .width(MIN_WIDTH - PADDING_WIDTH)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
        }
        .width(MIN_WIDTH)
        .padding({
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2')
        })
        .borderRadius('50%')
        .backgroundColor(this.isDark ? $r('sys.color.icon_on_tertiary') :
        $r('sys.color.comp_background_tertiary'))
        .margin({ right: $r('sys.float.padding_level8') })
        .bindPopup(this.displayPopup, {
          message: this.allTagStr,
          mask: false,
          popupColor: $r('sys.color.ohos_id_blur_style_component_regular_color'),
          shadow: ShadowStyle.OUTER_DEFAULT_SM,
          offset: { x: SampleDetailConstant.HOVER_POPUP_LEFT, y: 0 },
          autoCancel: true,
          radius: ($r('sys.float.corner_radius_level4')),
          messageOptions: {
            textColor: $r('sys.color.font_primary'),
            font: { size: $r('sys.float.Body_M') }
          }
        })
        .onHover((isHover: boolean) => {
          this.displayPopup = isHover;
          if (this.tags.length == 0) {
            this.displayPopup = false;
          }
        })
      }
    }
    .margin({ top: $r('sys.float.padding_level4') })
  }
}