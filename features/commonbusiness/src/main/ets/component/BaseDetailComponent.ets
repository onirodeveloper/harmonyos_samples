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

import { GlobalInfoModel, LoadingFailedView, LoadingStatus, LoadingView, NoNetworkView } from '@ohos/common';

@Component
export struct BaseDetailComponent {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop loadingStatus: LoadingStatus;
  @BuilderParam @Require detailContentView: () => void;
  @BuilderParam @Require topTitleView: () => void;
  reloadData?: Function;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.loadingStatus !== LoadingStatus.IDLE) {
        this.detailContentView()
      }
      if (this.loadingStatus === LoadingStatus.IDLE || this.loadingStatus === LoadingStatus.LOADING) {
        LoadingView(this.globalInfoModel.currentBreakpoint)
      } else if (this.loadingStatus === LoadingStatus.FAILED) {
        LoadingFailedView(this.globalInfoModel.currentBreakpoint, () => {
          this.reloadData?.();
        })
      } else if (this.loadingStatus === LoadingStatus.NO_NETWORK) {
        NoNetworkView(this.globalInfoModel.currentBreakpoint, () => {
          this.reloadData?.();
        })
      }
      this.topTitleView()
    }
    .backgroundColor(Color.Transparent)
  }
}