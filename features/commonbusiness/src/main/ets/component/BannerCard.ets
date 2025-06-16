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

import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, BreakpointTypeEnum, CommonConstants } from '@ohos/common';
import type { BannerData } from '../model/BannerData';
import type { BannerState } from '../viewmodel/BaseHomeState';
import { BannerItem } from './BannerItem';

const ICON_HEIGHT = 32;
const ICON_PADDING = 24;
const BANNER_ASPECT = 1.75;
const BANNER_DOT_HEIGHT = 2;
const BANNER_DOT_SPACING = 8;

@Component
export struct BannerCard {
  @StorageProp('GlobalInfoModel') @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get('GlobalInfoModel')!;
  @Prop @Require bannerState: BannerState;
  @Prop @Require tabViewType: number;
  handleItemClick?: (bannerData: BannerData) => void;
  private bannerPadding: number = new BreakpointType({
    sm: CommonConstants.SPACE_16,
    md: CommonConstants.SPACE_24,
    lg: CommonConstants.SPACE_32
  }).getValue(this.globalInfoModel.currentBreakpoint);
  private catchCount: number = this.bannerState.bannerResource.totalCount();
  private swiperController: SwiperController = new SwiperController();
  private scrollerController: Scroller = new Scroller();
  private bannerOffset: number = this.bannerState.bannerHeight * BANNER_ASPECT;
  @State currentIndex: number = 0;
  @State showLeftIcon: boolean = false;
  @State showRightIcon: boolean = true;
  @State bannerWidth: number =
    (this.globalInfoModel.deviceWidth - this.bannerPadding * 2 - BANNER_DOT_SPACING * (this.catchCount - 1)) /
    this.catchCount;

  handleBreakPointChange(): void {
    this.bannerPadding = new BreakpointType({
      sm: CommonConstants.SPACE_16,
      md: CommonConstants.SPACE_24,
      lg: CommonConstants.SPACE_32
    }).getValue(this.globalInfoModel.currentBreakpoint);
    if (this.globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.LG &&
      this.globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL) {
      this.bannerWidth =
        (this.globalInfoModel.deviceWidth - this.bannerPadding * 2 - BANNER_DOT_SPACING * (this.catchCount - 1)) /
        this.catchCount;
    }
  }

  build() {
    if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll(this.scrollerController) {
          Row({ space: CommonConstants.SPACE_16 }) {
            LazyForEach(this.bannerState.bannerResource, (bannerData: BannerData) => {
              Column() {
                BannerItem({ bannerData: bannerData })
                  .reuseId('banner_scroll')
                  .geometryTransition(CommonConstants.BANNER_GEOMETRY + bannerData.id.toString(), { follow: true })
                  .transition(TransitionEffect.OPACITY)
                  .height('100%')
                  .aspectRatio(BANNER_ASPECT)
                  .onClick(() => {
                    this.handleItemClick?.(bannerData);
                  })
              }
            }, (bannerData: BannerData) => bannerData.id.toString())
          }
          .justifyContent(FlexAlign.Start)
          .padding({
            left: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ?
              (CommonConstants.TAB_BAR_WIDTH + CommonConstants.SPACE_32) : $r('sys.float.padding_level16'),
            right: $r('sys.float.padding_level16'),
          })
        }
        .onReachStart(() => {
          this.showLeftIcon = false;
          this.showRightIcon = true;
        })
        .onReachEnd(() => {
          this.showLeftIcon = true;
          this.showRightIcon = false;
        })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .scrollable(ScrollDirection.Horizontal)
        .height('100%')
        .width('100%')

        if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize($r('app.float.banner_icon_height'))
              .fontColor([$r('sys.color.font_on_primary')])
          }
          .backgroundColor($r('sys.color.mask_fourth'))
          .height($r('app.float.banner_button_height'))
          .width($r('app.float.banner_button_height'))
          .margin({
            top: Math.floor((this.bannerState.bannerHeight -
              (this.globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT + CommonConstants.SPACE_8) -
              ICON_HEIGHT) / 2),
            left: $r('sys.float.padding_level12')
          })
          .visibility(this.showLeftIcon ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.scrollByOffset(-this.bannerOffset);
          })

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize($r('app.float.banner_icon_height'))
              .fontColor([$r('sys.color.font_on_primary')])
          }
          .backgroundColor($r('sys.color.mask_fourth'))
          .height($r('app.float.banner_button_height'))
          .width($r('app.float.banner_button_height'))
          .margin({
            top: Math.floor((this.bannerState.bannerHeight -
              (this.globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT + CommonConstants.SPACE_8) -
              ICON_HEIGHT) / 2),
            left: this.globalInfoModel.deviceWidth - CommonConstants.SIDE_BAR_WIDTH - CommonConstants.SPACE_32 * 2 -
              ICON_PADDING - ICON_HEIGHT,
          })
          .position({ x: 0 })
          .visibility(this.showRightIcon ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.scrollByOffset(this.bannerOffset);
          })
        }
      }
      .height(this.bannerState.bannerHeight)
      .width('100%')
      .padding({
        top: this.globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT + CommonConstants.SPACE_8,
      })
    } else {
      Swiper(this.swiperController) {
        LazyForEach(this.bannerState.bannerResource, (bannerData: BannerData) => {
          BannerItem({ bannerData: bannerData })
            .reuseId('banner_swiper')
            .onClick(() => {
              this.handleItemClick?.(bannerData);
            })
        }, (bannerData: BannerData) => bannerData.id.toString())
      }
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .cachedCount(this.catchCount)
      .itemSpace(0)
      .loop(true)
      .autoPlay(this.catchCount > 1)
      .effectMode(EdgeEffect.None)
      .indicator(this.catchCount > 1 ?
      new DotIndicator()
        .itemWidth(this.bannerWidth)
        .itemHeight(BANNER_DOT_HEIGHT)
        .color($r('sys.color.icon_on_tertiary'))
        .selectedItemWidth(this.bannerWidth)
        .selectedItemHeight(BANNER_DOT_HEIGHT)
        .selectedColor($r('sys.color.icon_on_primary')) :
        false)
      .width('100%')
      .height(this.bannerState.bannerHeight)
      .geometryTransition(CommonConstants.BANNER_GEOMETRY + this.tabViewType.toString(), { follow: true })
      .transition(TransitionEffect.OPACITY)
    }
  }

  private scrollByOffset(offset: number): void {
    const currentOffset = this.scrollerController.currentOffset().xOffset;
    this.scrollerController.scrollTo({
      xOffset: currentOffset + offset, yOffset: 0, animation: {
        duration: 200,
      }
    });
  }
}