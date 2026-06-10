/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { MainViewModel, MainEventType } from '../viewmodel/MainViewModel';
import { CommonConstants, TRACK_KEY, TrackNode, TrackServiceData, InteractionTypeEnum } from '@ohos/common';
import { SingleSampleData } from '@ohos/devpractices';
import { Logger } from '@ohos/common';
import { MainState } from '../viewmodel/MainState';
import { QRCodeSheet } from './QRCodeSheet';

const TAG: string = '[HomeContent]';

@Component
export struct HomeContent {
  @State viewModel: MainViewModel = MainViewModel.getInstance();
  @State mainState: MainState = this.viewModel.getState();
  @State bindQRCode: boolean = false;
  @State sampleURL: string = '';
  @State sampleTitle: string = '';
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear(): void {
    Logger.info(TAG, 'HomeContent aboutToAppear');
    this.viewModel.sendEvent({ type: MainEventType.INIT });
  }

  build() {
    Stack() {
      QRCodeSheet({
        bindQRCode: this.bindQRCode,
        sampleURL: this.sampleURL,
        sampleTitle: this.sampleTitle
      })
      Stack() {
        this.bannerSection()
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignContent(Alignment.Bottom)
    }
    .layoutWeight(1)
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  bannerSection() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.mainState.bannerList, (banner: SingleSampleData, index: number) => {
          this.bannerBuilder(banner)
        }, (banner: SingleSampleData) => banner.id.toString())
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .loop(true)
      .autoPlay(this.bindQRCode ? false : true)
      .onChange((index: number) => {
        this.mainState.currentBannerIndex = index;
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  bannerBuilder(banner: SingleSampleData) {
    TrackNode() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($rawfile(`${banner.mediaInfoList[0].mediaUrl}`))
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
        this.actionButtons()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .customProperty(TRACK_KEY, {
        interactionContent: banner.title,
        interactionType: InteractionTypeEnum.SAMPLE,
      } as TrackServiceData)
    }
  }

  @Builder
  actionButtons() {
    Row() {
      Button($r('app.string.experience_now'))
        .fontSize($r('app.float.home_content_button_font_size'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.background_emphasize'))
        .fontColor($r('sys.color.font_primary'))
        .borderRadius($r('app.float.home_content_button_border_radius'))
        .focusable(true)
        .onClick(() => {
          this.viewModel.sendEvent({ type: MainEventType.EXPERIENCE_CLICK, data: this.mainState.currentBannerIndex });
        })
        .margin({
          left: CommonConstants.SPACE_8,
          right: CommonConstants.SPACE_8,
        })
        .padding({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16,
          top: $r('app.float.home_content_button_padding_vertical'),
          bottom: $r('app.float.home_content_button_padding_vertical')
        })

      Button($r('app.string.view_source'))
        .fontSize($r('app.float.home_content_button_font_size'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.font_emphasize'))
        .borderRadius($r('app.float.home_content_button_border_radius'))
        .borderColor($r('sys.color.icon_on_fourth'))
        .focusable(true)
        .margin({
          left: CommonConstants.SPACE_8,
          right: CommonConstants.SPACE_8,
        })
        .padding({
          left: CommonConstants.SPACE_16,
          right: CommonConstants.SPACE_16,
          top: $r('app.float.home_content_button_padding_vertical'),
          bottom: $r('app.float.home_content_button_padding_vertical')
        })
        .onClick(() => {
          this.viewModel.sendEvent({ type: MainEventType.SOURCE_CLICK });
          this.bindQRCode = true;
          this.sampleURL = this.mainState.getSampleUrl();
          this.sampleTitle = this.mainState.getSampleTitle();
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('app.float.home_content_action_buttons_left_padding'),
      bottom: $r('app.float.home_content_action_buttons_bottom_padding')
    })
  }
}
