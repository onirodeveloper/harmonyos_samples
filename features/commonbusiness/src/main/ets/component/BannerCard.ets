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

import {
  ActionName,
  CommonConstants,
  GlobalInfoModel,
  HdsUtil,
  InteractionTypeEnum,
  StorageKey,
  TRACK_KEY,
  TrackNode,
  TrackServiceData,
  BreakpointType,
} from '@ohos/common';
import type { BannerData } from '../model/BannerData';
import type { BannerState } from '../viewmodel/BaseHomeState';
import { BannerItem } from './BannerItem';
import { BannerProgress } from './BannerProgress';
import { ProgressController } from './ProgressController';

const BANNER_ASPECT = 1.75;
const ANIMATION_DELAY = 50;

@Component
export struct BannerCard {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = new GlobalInfoModel();
  @Prop @Require bannerState: BannerState;
  @Prop @Require tabViewType: number;
  handleItemClick?: (bannerData: BannerData) => void;
  private swiperController: SwiperController = new SwiperController();
  private scrollerController: Scroller = new Scroller();
  private bannerOffset: number = this.bannerState.bannerHeight * BANNER_ASPECT;
  private isAnimating: boolean = false;
  private timer?: number;
  @State cachedCount: number = this.bannerState.bannerResource.totalCount();
  @State progressController: ProgressController = new ProgressController();
  @State currentIndex: number = 0;
  @State showLeftIcon: boolean = false;
  @State showRightIcon: boolean = true;

  aboutToDisappear(): void {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = undefined;
    }
  }

  @Builder
  BannerSwiperBuilder() {
    Swiper(this.swiperController) {
      ForEach(this.bannerState.bannerResource.splashArray, (bannerData: BannerData) => {
        TrackNode() {
          BannerItem({ bannerData: bannerData, widthBreakpoint: this.globalInfoModel.widthBreakpoint })
            .onClick(() => {
              this.handleItemClick?.(bannerData);
            })
            .customProperty(TRACK_KEY, {
              interactionContent: bannerData.title,
              interactionType: InteractionTypeEnum.ARTICLE,
              actionName: ActionName.ARTICLE_CLICK
            } as TrackServiceData)
        }
      }, (bannerData: BannerData) => bannerData.id.toString())
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .cachedCount(this.cachedCount)
    .loop(true)
    .autoPlay(this.cachedCount > 1)
    .effectMode(EdgeEffect.None)
    .indicator(false)
    .width('100%')
    .height(this.bannerState.bannerHeight)
    .onAnimationStart((index: number, targetIndex: number) => {
      this.isAnimating = true;
      if (index === targetIndex) {
        this.progressController.restartBannerProgress();
      } else {
        this.currentIndex = targetIndex;
      }
    })
    .onAnimationEnd(() => {
      this.isAnimating = false;
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.progressController.stopBannerProgress();
      } else if (event.type === TouchType.Up) {
        if (!this.isAnimating) {
          if (this.timer) {
            clearTimeout(this.timer);
          }
          this.timer = setTimeout(() => {
            this.progressController.restartBannerProgress();
          }, ANIMATION_DELAY)
        }
      }
    })
  }

  build() {
    if (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ||
      AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
      RelativeContainer() {
        Scroll(this.scrollerController) {
          Row({ space: CommonConstants.SPACE_16 }) {
            LazyForEach(this.bannerState.bannerResource, (bannerData: BannerData) => {
              Column() {
                BannerItem({ bannerData: bannerData, widthBreakpoint: this.globalInfoModel.widthBreakpoint })
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
            left: new BreakpointType({
              sm: $r('sys.float.padding_level8'),
              md: $r('sys.float.padding_level12'),
              lg: !HdsUtil.isSupportNewMaterialApi() && !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
                (CommonConstants.TAB_BAR_WIDTH + CommonConstants.SPACE_32) : $r('sys.float.padding_level16'),
            }).getValue(this.globalInfoModel.widthBreakpoint),
            right: new BreakpointType({
              sm: $r('sys.float.padding_level8'),
              md: $r('sys.float.padding_level12'),
              lg: $r('sys.float.padding_level16'),
            }).getValue(this.globalInfoModel.widthBreakpoint),
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

        if (AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize($r('app.float.banner_icon_height'))
              .fontColor([$r('sys.color.font_on_primary')])
          }
          .backgroundColor($r('sys.color.mask_fourth'))
          .height($r('app.float.banner_button_height'))
          .width($r('app.float.banner_button_height'))
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
          })
          .margin({
            left: new BreakpointType({
              sm: $r('sys.float.padding_level8'),
              md: $r('sys.float.padding_level12'),
              lg: $r('sys.float.padding_level16'),
            }).getValue(this.globalInfoModel.widthBreakpoint)
          })
          .zIndex(2)
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
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            right: { anchor: '__container__', align: HorizontalAlign.End },
          })
          .margin({
            right: new BreakpointType({
              sm: $r('sys.float.padding_level8'),
              md: $r('sys.float.padding_level12'),
              lg: $r('sys.float.padding_level16'),
            }).getValue(this.globalInfoModel.widthBreakpoint)
          })
          .zIndex(2)
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
      Stack({ alignContent: Alignment.Bottom }) {
        this.BannerSwiperBuilder();
        BannerProgress({
          progressController: this.progressController,
          currentIndex: this.currentIndex,
          totalCount: this.cachedCount
        })
      }
      .onVisibleAreaChange([0.0], (_isVisible: boolean, currentRatio: number) => {
        if (currentRatio > 0) {
          this.progressController.restartBannerProgress();
        } else {
          this.progressController.stopBannerProgress();
        }
      })
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