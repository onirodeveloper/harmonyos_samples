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
import { displaySync } from '@kit.ArkGraphics2D';
import {
  CommonConstants,
  LoadingStatus,
  TopNavigationView,
  WebUtil,
  WindowUtil,
} from '@ohos/common';
import { BaseDetailComponent, ComponentDetailParams } from '@ohos/commonbusiness';
import {
  ComponentDetailEvent,
  ComponentDetailEventType,
  ComponentDetailPageVM,
  InitComponentEvent,
} from '../viewmodel/ComponentDetailPageVM';
import { DetailContentView } from '../component/DetailContentView';
import type { ComponentDetailState } from '../viewmodel/ComponentDetailState';
import { ComponentDetailManager } from '../viewmodel/ComponentDetailManager';
import { CodePreviewJSUtil } from '../util/CodePreviewJSUtil';
import { RecommendData } from '../model/ComponentDetailData';

@Component({ freezeWhenInactive: true })
export struct ComponentDetailView {
  @StorageProp('systemColorMode') systemColorMode: ConfigurationConstant.ColorMode = AppStorage.get('systemColorMode')!;
  @StorageLink('webIsLoading') @Watch('sendCodeToWeb') webIsLoading: boolean = false;
  @Prop componentName: string = '';
  @Prop componentId: number = 0;
  private displaySync = displaySync.create();
  private viewModel?: ComponentDetailPageVM;
  @State componentDetailState?: ComponentDetailState = this.viewModel?.getState();
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;

  aboutToAppear(): void {
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    WindowUtil.updateStatusBarColor(getContext(this), isSystemDark);
  }

  aboutToDisappear(): void {
    CommonConstants.PROMISE_WAIT(CommonConstants.REMOVE_DURATION).then(() => {
      this.componentDetailState?.recommends.forEach((item: RecommendData) => {
        WebUtil.removeNode(item.url);
      });
    });
  }

  @Builder
  DetailContentBuilder() {
    DetailContentView({
      componentDetailState: this.componentDetailState,
      componentName: this.componentName,
    })
      .layoutWeight(1)
  }

  @Builder
  TopTitleViewBuilder() {
    TopNavigationView({
      topNavigationData: this.componentDetailState?.topNavigationData,
    })
  }

  build() {
    NavDestination() {
      BaseDetailComponent({
        detailContentView: () => {
          this.DetailContentBuilder()
        },
        topTitleView: () => {
          this.TopTitleViewBuilder()
        },
        loadingStatus: this.loadingStatus,
      })
        .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
    }
    .hideTitleBar(true)
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .onDisAppear(() => {
      this.displaySync.stop();
    })
    .onReady((ctx: NavDestinationContext) => {
      const params: ComponentDetailParams = ctx.pathInfo.param as ComponentDetailParams;
      this.componentName = params.componentName as string;
      this.componentId = Number(params.componentId);
      CommonConstants.PROMISE_WAIT(500).then(() => {
        this.assignViewData();
      });
    })
  }

  assignViewData() {
    this.viewModel = ComponentDetailManager.getInstance().getDetailViewModel(this.componentName);
    if (!this.viewModel) {
      this.viewModel = new ComponentDetailPageVM(this.componentName);
    }
    const range: ExpectedFrameRateRange = { expected: 120, min: 60, max: 120 };
    this.displaySync.setExpectedFrameRateRange(range);
    let frameCount = 0;
    const eventList: ComponentDetailEventType[] = [
      ComponentDetailEventType.INIT_DESCRIPTOR,
      ComponentDetailEventType.INIT_RECOMMEND,
      ComponentDetailEventType.WEB_CODE_EVENT,
    ];
    const eventCount = eventList.length;
    this.viewModel?.sendEvent(new InitComponentEvent(this.componentId))?.then(() => {
      this.componentDetailState = this.viewModel?.getState();
      this.loadingStatus = LoadingStatus.LOADING;
      this.displaySync.on('frame', () => {
        const promise = this.viewModel?.sendEvent(new ComponentDetailEvent(eventList[frameCount]));
        this.componentDetailState = this.viewModel?.getState();
        frameCount++;
        if (frameCount >= eventCount) {
          promise?.then(() => {
            this.displaySync.stop();
            this.refreshCodePreviewWeb();
          });
        }
      });
      this.displaySync.start();
    });
  }

  refreshCodePreviewWeb() {
    this.webIsLoading = true;
    WebUtil.getWebController(WebUtil.getComponentCodeUrl())?.refresh();
  }

  sendCodeToWeb() {
    if (this.loadingStatus === LoadingStatus.LOADING && !this.webIsLoading) {
      const codeToHtmlMethod: string = 'codeToHtml(%param)';
      const params: string = `${JSON.stringify(this.componentDetailState?.code)}, ${this.systemColorMode}`;
      CodePreviewJSUtil.codeViewRunJS(codeToHtmlMethod, params, () => {
        this.loadingStatus = LoadingStatus.SUCCESS;
      });
    }
  }
}

@Builder
export function ComponentDetailBuilder() {
  ComponentDetailView()
}