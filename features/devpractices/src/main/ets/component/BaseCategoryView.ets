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

import {
  EmptyContentView,
  GlobalInfoModel,
  LoadingFailedView,
  LoadingStatus,
  LoadingView,
  NoNetworkView,
  StorageKey,
} from '@ohos/common';
import type { LoadingModel } from '@ohos/common';
import { BaseHomeEventType, TabBarAnimationParam, TabBarType } from '@ohos/commonbusiness';
import { PracticeViewModel } from '../viewmodel/PracticeViewModel';

@Component
export struct BaseCategoryView {
  viewModel: PracticeViewModel = PracticeViewModel.getInstance();
  @Prop @Require loadingModel: LoadingModel;
  @BuilderParam @Require contentView: () => void;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  scroller: Scroller = new Scroller();
  reloadData?: Function;

  build() {
    Scroll(this.scroller) {
      if (this.loadingModel.loadingStatus === LoadingStatus.SUCCESS) {
        this.contentView()
      } else {
        Column() {
          if (this.loadingModel.loadingStatus === LoadingStatus.FAILED) {
            LoadingFailedView(this.globalInfoModel.widthBreakpoint, () => {
              this.reloadData?.();
            })
          } else if (this.loadingModel.loadingStatus === LoadingStatus.LOADING) {
            LoadingView(this.globalInfoModel.widthBreakpoint)
          } else if (this.loadingModel.loadingStatus === LoadingStatus.NO_NETWORK) {
            NoNetworkView(this.globalInfoModel.widthBreakpoint, () => {
              this.reloadData?.();
            })
          } else {
            EmptyContentView($r('app.media.ic_browse_no'), $r('app.string.no_content'), () => {
              this.reloadData?.();
            })
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
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      if (state === ScrollState.Scroll && offset < 0) {
        this.viewModel.sendEvent<TabBarAnimationParam>({
          type: BaseHomeEventType.HANDLE_TAB_BAR_ANIMATION,
          param: {
            yOffset: offset,
            tabIndex: TabBarType.SAMPLE,
          } as TabBarAnimationParam,
        });
      }
      return { offsetRemain: offset };
    })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
  }
}