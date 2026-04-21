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

import { LoadingView } from './LoadingView';

const LOADING_DELAY_THRESHOLD: number = 200;

@Component
export struct DelayedLoadingView {
  @Prop breakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @Prop delayThreshold: number = LOADING_DELAY_THRESHOLD
  @State private showLoading: boolean = false;
  private delayTimer: number = -1;

  aboutToAppear(): void {
    this.delayTimer = setTimeout(() => {
      this.showLoading = true;
    }, LOADING_DELAY_THRESHOLD);
  }

  aboutToDisappear(): void {
    if (this.delayTimer !== -1) {
      clearTimeout(this.delayTimer);
      this.delayTimer = -1;
    }
  }

  build() {
    if (this.showLoading) {
      LoadingView(this.breakpoint)
    }
  }
}
