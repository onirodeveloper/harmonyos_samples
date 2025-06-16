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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import type { GlobalInfoModel } from '@ohos/common';
import { CommonConstants, LoadingStatus, TopNavigationView, WindowUtil } from '@ohos/common';
import { BaseDetailComponent, SampleDetailParams } from '@ohos/commonbusiness';
import { SampleComponent } from '../component/SampleComponent';
import type { SampleDetailData, SampleDetailState } from '../viewmodel/SampleDetailState';
import {
  InitSampleDetailEvent,
  PopEvent,
  SampleDetailPageVM,
  SetIndexEvent,
} from '../viewmodel/SampleDetailPageVM';

@Builder
export function SampleDetailViewBuilder() {
  SampleDetailView()
}

@Component
export struct SampleDetailView {
  @StorageProp('systemColorMode') @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get('systemColorMode')!;
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  viewModel: SampleDetailPageVM = SampleDetailPageVM.getInstance();
  @State sampleDetailState: SampleDetailState = this.viewModel.getState();
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;
  @Provide currentIndex: number = -1;
  private sampleCardId: number = -1;

  aboutToAppear(): void {
    this.handleColorModeChange();
  }

  handleColorModeChange() {
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    WindowUtil.updateStatusBarColor(getContext(this), isSystemDark);
  }

  private onBack(): void {
    if (!this.sampleDetailState.isBackPressed) {
      this.viewModel.sendEvent(new PopEvent());
    }
  }

  @Builder
  SampleDetailBuilder() {
    Swiper() {
      ForEach(this.sampleDetailState.sampleDatas, (item: SampleDetailData, index: number) => {
        SampleComponent({
          singleSampleData: item,
          sampleIndex: index,
          showIndicator: this.sampleDetailState.sampleCount > 1,
        })
      }, (item: SampleDetailData) => item.id.toString())
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ top: (this.globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT) })
    .indicator(this.sampleDetailState.sampleCount > 1)
    .index(this.currentIndex)
    .disableSwipe(this.sampleDetailState.sampleCount === 1 || this.sampleDetailState.installingStatus ||
    this.sampleDetailState.downloadingStatus)
    .onChange((index: number) => {
      this.viewModel.sendEvent(new SetIndexEvent(index));
      this.currentIndex = index;
    })
    .gesture(
      SwipeGesture({ direction: SwipeDirection.Horizontal })
        .onAction(() => {
          if (this.sampleDetailState.sampleDatas[this.currentIndex].sampleCard.downloadProgress >= 0 &&
            this.sampleDetailState.sampleCount > 1) {
            promptAction.showToast({ message: $r('app.string.swiper_gesture') });
          }
        })
    )
  }

  @Builder
  TopTitleViewBuilder() {
    TopNavigationView({
      topNavigationData: {
        title: $r('app.string.sample_title'),
        onBackClick: () => {
          this.onBack();
        }
      },
    })
  }

  build() {
    NavDestination() {
      BaseDetailComponent({
        detailContentView: () => {
          this.SampleDetailBuilder()
        },
        topTitleView: () => {
          this.TopTitleViewBuilder()
        },
        loadingStatus: this.sampleDetailState.loadingStatus,
      })
    }
    .onReady((cxt: NavDestinationContext) => {
      const params = cxt.pathInfo.param as SampleDetailParams;
      this.sampleCardId = params.sampleCardId;
      this.currentIndex = params.currentIndex;
      this.viewModel.sendEvent(new InitSampleDetailEvent(this.sampleCardId, params.currentIndex));
    })
    .onBackPressed(() => {
      this.onBack();
      return true;
    })
    .onWillShow(() => {
      this.sampleDetailState.isBackPressed = false;
    })
    .onWillHide(() => {
      this.sampleDetailState.isBackPressed = false;
    })
    .hideTitleBar(true)
    .padding({ bottom: this.globalInfoModel.naviIndicatorHeight, top: this.globalInfoModel.statusBarHeight })
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}