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
import { SampleCardData, SampleContent } from '../model/SampleData';
import { TagLabel } from './TagLabel';

const ITEM_HEIGHT: number = 340;
const ITEM_ASPECT: number = 0.74;
const LOG_MAX_WIDTH: number = 202;

@Component
export struct SampleScrollCard {
  @StorageProp('GlobalInfoModel') @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get('GlobalInfoModel')!;
  @Prop sampleCardData: SampleCardData;
  handleItemClick?: Function;
  @State sampleItemWidth: number = ITEM_HEIGHT * ITEM_ASPECT;
  @State horizontalPadding: Resource = new BreakpointType({
    sm: $r('sys.float.padding_level8'),
    md: $r('sys.float.padding_level12'),
    lg: $r('sys.float.padding_level16'),
  }).getValue(this.globalInfoModel.currentBreakpoint);
  @State contentOffset: number = new BreakpointType({
    sm: CommonConstants.SPACE_16,
    md: CommonConstants.SPACE_24,
    lg: CommonConstants.SPACE_32,
  }).getValue(this.globalInfoModel.currentBreakpoint);

  aboutToAppear(): void {
    this.handleBreakPointChange();
  }

  handleBreakPointChange() {
    const barWidth =
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? CommonConstants.SIDE_BAR_WIDTH :
      CommonConstants.TAB_BAR_WIDTH;
    this.horizontalPadding = new BreakpointType({
      sm: $r('sys.float.padding_level8'),
      md: $r('sys.float.padding_level12'),
      lg: $r('sys.float.padding_level16'),
    }).getValue(this.globalInfoModel.currentBreakpoint);
    this.contentOffset = new BreakpointType({
      sm: CommonConstants.SPACE_16,
      md: CommonConstants.SPACE_24,
      lg: CommonConstants.SPACE_32,
    }).getValue(this.globalInfoModel.currentBreakpoint);
    if ((this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) &&
      this.sampleCardData.sampleContents.length === 3) {
      this.sampleItemWidth = (this.globalInfoModel.deviceWidth - barWidth - 64 - 32) / 3;
    } else if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ||
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.MD) {
      this.sampleItemWidth = ITEM_HEIGHT * ITEM_ASPECT;
    } else {
      this.sampleItemWidth = Math.floor((this.globalInfoModel.deviceWidth - barWidth - 64 - 32) / 3.5);
    }
  }

  @Builder
  SampleItemBuilder(item: SampleContent, index: number) {
    Column() {
      Column() {
        Image($rawfile(item.mediaUrl))
          .draggable(false)
          .alt($r('app.media.img_placeholder'))
          .objectFit(ImageFit.Contain)
          .height('100%')
      }
      .layoutWeight(1)

      Column() {
        Text(item.title)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        TagLabel({ tags: item.tags, maxWidth: LOG_MAX_WIDTH })
      }
      .width('100%')
      .padding({ top: $r('sys.float.padding_level8') })
      .renderGroup(true)
    }
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .onClick(() => this.handleItemClick?.(index, this.sampleCardData.sampleContents))
    .padding($r('sys.float.padding_level8'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .height($r('app.float.card_scroll_height'))
    .width(this.sampleItemWidth)
  }

  build() {
    Column() {
      Column() {
        Text(this.sampleCardData.cardTitle)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.ohos_id_color_foreground'))
          .fontWeight(FontWeight.Bold)
        Text(this.sampleCardData.cardSubTitle)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({
            top: $r('sys.float.padding_level2'),
            bottom: $r('sys.float.padding_level6'),
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({
        left: this.horizontalPadding,
        right: this.horizontalPadding,
      })

      List({ space: CommonConstants.SPACE_16 }) {
        Repeat(this.sampleCardData.sampleContents).each((repeatItem: RepeatItem<SampleContent>) => {
          ListItem() {
            this.SampleItemBuilder(repeatItem.item, repeatItem.index)
          }
        })
          .virtualScroll()
          .key((item: SampleContent) => item.id.toString())
      }
      .cachedCount(3)
      .contentStartOffset(this.contentOffset)
      .contentEndOffset(this.contentOffset)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .width('100%')
      .height($r('app.float.card_scroll_height'))
    }
    .alignItems(HorizontalAlign.Start)
  }
}