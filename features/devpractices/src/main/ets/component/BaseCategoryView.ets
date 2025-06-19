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

import { EmptyContentView, LoadingFailedView, LoadingStatus, LoadingView, NoNetworkView } from '@ohos/common';
import type { GlobalInfoModel, LoadingModel } from '@ohos/common';

@Component
export struct BaseCategoryView {
  @Prop @Require loadingModel: LoadingModel;
  @BuilderParam @Require contentView: () => void;
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  scroller: Scroller = new Scroller();
  reloadData?: Function;

  build() {
    Scroll() {
      if (this.loadingModel.loadingStatus === LoadingStatus.SUCCESS) {
        this.contentView()
      } else {
        Column() {
          if (this.loadingModel.loadingStatus === LoadingStatus.FAILED) {
            LoadingFailedView(this.globalInfoModel.currentBreakpoint, () => {
              this.reloadData?.();
            })
          } else if (this.loadingModel.loadingStatus === LoadingStatus.LOADING) {
            LoadingView(this.globalInfoModel.currentBreakpoint)
          } else if (this.loadingModel.loadingStatus === LoadingStatus.NO_NETWORK) {
            NoNetworkView(this.globalInfoModel.currentBreakpoint, () => {
              this.reloadData?.();
            })
          } else {
            EmptyContentView($r('app.media.ic_browse_no'), $r('app.string.no_content'))
          }
        }
        .width('100%')
        .height($r('app.float.loading_view_height'))
      }
    }
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor($r('sys.color.background_secondary'))
    .height('100%')
    .width('100%')
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
  }
}