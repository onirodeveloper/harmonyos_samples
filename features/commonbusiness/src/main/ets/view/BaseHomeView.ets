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

import type { GlobalInfoModel, LoadingModel } from '@ohos/common';
import { LoadingFailedView, LoadingStatus, LoadingView, NoNetworkView } from '@ohos/common';

@Component
export struct BaseHomeView {
  @Prop @Require loadingModel: LoadingModel;
  @BuilderParam @Require contentView: () => void;
  @BuilderParam @Require topTitleView: () => void;
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  reloadData?: Function;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.loadingModel.loadingStatus === LoadingStatus.SUCCESS) {
        this.contentView()
      } else if (this.loadingModel.loadingStatus === LoadingStatus.FAILED) {
        LoadingFailedView(this.globalInfoModel.currentBreakpoint, () => {
          this.reloadData?.();
        })
      } else if (this.loadingModel.loadingStatus === LoadingStatus.LOADING) {
        LoadingView(this.globalInfoModel.currentBreakpoint)

      } else if (this.loadingModel.loadingStatus === LoadingStatus.NO_NETWORK) {
        NoNetworkView(this.globalInfoModel.currentBreakpoint, () => {
          this.reloadData?.();
        })
      }
      this.topTitleView()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }
}