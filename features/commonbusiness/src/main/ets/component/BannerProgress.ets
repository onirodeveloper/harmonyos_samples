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

import { CommonConstants } from '@ohos/common';
import { BannerConstants } from '../constant/BannerConstants';
import { ProgressController, ProgressState } from './ProgressController';

@Component
export struct BannerProgress {
  @State progressArray: number[] = [];
  @State currentProgressValue: number = 0;
  @Link @Watch('handleProgressControllerChange') progressController: ProgressController;
  @Prop @Watch('updateCurrentProgress') currentIndex: number;
  @Prop @Watch('updateProgressArray') totalCount: number;
  private intervalID: number = -1;

  aboutToAppear(): void {
    this.updateProgressArray();
    this.updateCurrentProgress();
  }

  aboutToDisappear(): void {
    this.currentProgressValue = 0;
    clearInterval(this.intervalID);
  }

  private handleProgressControllerChange() {
    if (this.progressController.getProgressState() === ProgressState.STOP) {
      clearInterval(this.intervalID);
    } else if (this.progressController.getProgressState() === ProgressState.RESTART) {
      this.updateCurrentProgress();
    }
  }

  private updateProgressArray(): void {
    this.progressArray.length = this.totalCount;
    this.progressArray.fill(1);
  }

  private updateCurrentProgress(): void {
    this.currentProgressValue = 0;
    clearInterval(this.intervalID);
    this.intervalID = setInterval(() => {
      this.currentProgressValue += BannerConstants.FRAME_TIME;
      if (this.currentProgressValue >= BannerConstants.PROGRESS_VALUE_MAX) {
        clearInterval(this.intervalID);
      }
    }, BannerConstants.FRAME_TIME)
  }

  build() {
    Row({ space: CommonConstants.SPACE_6 }) {
      ForEach(this.progressArray, (item: number, index: number) => {
        Progress({
          value: index === this.currentIndex ? this.currentProgressValue :
            (index < this.currentIndex ? BannerConstants.PROGRESS_VALUE_MAX : 0),
          total: BannerConstants.PROGRESS_VALUE_MAX,
          type: ProgressType.Linear
        })
          .color($r('app.color.banner_progress_color'))
          .style({
            strokeWidth: $r('sys.float.border_extra_larger'),
            enableSmoothEffect: false,
          })
          .backgroundColor($r('sys.color.icon_on_fourth'))
          .flexShrink(1)
      })
    }
    .width('100%')
    .padding({
      bottom: $r('sys.float.padding_level7'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }
}