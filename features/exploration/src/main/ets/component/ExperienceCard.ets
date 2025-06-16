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

import { curves } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, BreakpointTypeEnum, CommonConstants, ProductSeriesEnum } from '@ohos/common';
import type { DiscoverContent } from '../model/DiscoverData';
import { ExperienceItem } from './ExperienceItem';

const ROW_PADDING = 64;
const SHOW_COUNT = 3;
const ENLARGE_COEFFICIENTS = 2;

@Component
export struct ExperienceCard {
  @StorageProp('GlobalInfoModel') @Watch('calculateItemWidth') globalInfoModel: GlobalInfoModel =
    AppStorage.get('GlobalInfoModel')!;
  @Prop @Require discoverContents: DiscoverContent[];
  handleItemClick?: Function;
  componentWidth: number = this.globalInfoModel.deviceWidth;
  scroller: Scroller = new Scroller()
  @State enlargeIndex: number = -1;
  @State itemWidth: number = 0;

  aboutToAppear(): void {
    this.calculateItemWidth();
  }

  calculateItemWidth() {
    if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      this.componentWidth = this.globalInfoModel.deviceWidth - CommonConstants.SIDE_BAR_WIDTH - ROW_PADDING;
      this.itemWidth = (this.componentWidth - CommonConstants.SPACE_16 * (SHOW_COUNT - 1)) / SHOW_COUNT;
    }
  }

  onHoverAction(isHover: boolean, index: number) {
    animateTo({ curve: curves.interpolatingSpring(0, 1, 288, 30) }, () => {
      if (isHover && this.enlargeIndex !== index) {
        const currentOffsetX: number = this.scroller.currentOffset().xOffset;
        // Items at the edge of the screen are not processed.
        if (((index * (this.itemWidth + CommonConstants.SPACE_16) - currentOffsetX) < -CommonConstants.SPACE_16) ||
          ((index + 1) * this.itemWidth - currentOffsetX) > this.componentWidth) {
          return;
        }
        // Calculate the position of the current item on the screen.
        const currentItemEdgePosition: number =
          (index + ENLARGE_COEFFICIENTS) * this.itemWidth - currentOffsetX;
        this.enlargeIndex = index;
        if (currentItemEdgePosition > this.componentWidth) {
          this.scroller.scrollTo({
            xOffset: (currentOffsetX + this.itemWidth +
            CommonConstants.SPACE_16),
            yOffset: 0,
          });
        }
      } else if (!isHover) {
        this.enlargeIndex = -1;
      }
    });
  }

  build() {
    if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      Scroll(this.scroller) {
        Row({ space: CommonConstants.SPACE_16 }) {
          ForEach(this.discoverContents, (discoverContent: DiscoverContent, index: number) => {
            ExperienceItem({ discoverContent: discoverContent })
              .height('100%')
              .width(index === this.enlargeIndex ?
                (this.itemWidth * ENLARGE_COEFFICIENTS + CommonConstants.SPACE_16) : this.itemWidth)
              .onHover((isHover: boolean) => this.onHoverAction(isHover, index))
              .onClick(() => {
                this.handleItemClick?.(discoverContent);
              })
          }, (discoverContent: DiscoverContent) => discoverContent.id.toString())
        }
        .padding({
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        })
        .height('100%')
      }
      .scrollSnap({ snapAlign: ScrollSnapAlign.START, snapPagination: this.itemWidth + CommonConstants.SPACE_16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .scrollable(ScrollDirection.Horizontal)
      .height($r('app.float.img_card_height'))
      .width('100%')
    } else {
      Swiper() {
        ForEach(this.discoverContents, (discoverContent: DiscoverContent) => {
          ExperienceItem({ discoverContent: discoverContent })
            .onClick(() => {
              this.handleItemClick?.(discoverContent);
            })
        }, (discoverContent: DiscoverContent) => discoverContent.id.toString())
      }
      .prevMargin(new BreakpointType<Length>({
        sm: 0,
        md: $r('sys.float.padding_level6'),
        lg: CommonConstants.SPACE_16 + CommonConstants.TAB_BAR_WIDTH,
      }).getValue(this.globalInfoModel.currentBreakpoint))
      .nextMargin(new BreakpointType<Length>({
        sm: 0,
        md: $r('sys.float.padding_level6'),
        lg: $r('sys.float.padding_level8'),
      }).getValue(this.globalInfoModel.currentBreakpoint))
      .loop(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM)
      .itemSpace(new BreakpointType({
        sm: CommonConstants.SPACE_8,
        md: CommonConstants.SPACE_12,
        lg: CommonConstants.SPACE_16,
      }).getValue(this.globalInfoModel.currentBreakpoint))
      .displayCount(new BreakpointType({
        sm: CommonConstants.LANE_SM,
        md: CommonConstants.LANE_MD,
        lg: CommonConstants.LANE_LG,
      }).getValue(this.globalInfoModel.currentBreakpoint))
      .effectMode(EdgeEffect.None)
      .indicator((this.discoverContents.length > 1 &&
        this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM) ?
      new DotIndicator()
        .color($r('sys.color.icon_on_tertiary'))
        .selectedColor($r('sys.color.icon_on_primary')) :
        false)
      .width('100%')
      .height(deviceInfo.productSeries === ProductSeriesEnum.VDE ? $r('app.float.img_card_height_verde') :
      $r('app.float.img_card_height'))
    }
  }
}