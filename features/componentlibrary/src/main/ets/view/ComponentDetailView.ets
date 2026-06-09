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
  hdsMaterial,
  HdsNavDestination,
  HdsNavDestinationAttribute,
  ScrollEffectType,
  TitleBarStyleOptions,
} from '@kit.UIDesignKit';
import {
  BreakpointType,
  CommonConstants,
  FeedbackDomain,
  FeedbackSheet,
  GlobalInfoModel,
  HdsUtil,
  LoadingStatus,
  StatusBarColorType,
  StorageKey,
  WebUtil,
} from '@ohos/common';
import { BaseDetailComponent, ComponentDetailParams } from '@ohos/commonbusiness';
import {
  AssignPathStackEvent,
  BackPage,
  ChangeBackPressed,
  ComponentDetailEvent,
  ComponentDetailEventType,
  ComponentDetailPageVM,
  InitComponentEvent,
} from '../viewmodel/ComponentDetailPageVM';
import { DetailContentView } from '../component/DetailContentView';
import type { ComponentDetailState } from '../viewmodel/ComponentDetailState';
import { ComponentDetailManager } from '../viewmodel/ComponentDetailManager';
import { RecommendData } from '../model/ComponentDetailData';

const TAG = '[ComponentDetailView]';

@Component({ freezeWhenInactive: true })
export struct ComponentDetailView {
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @Prop componentName: string = '';
  @Prop componentId: number = 0;
  @State loadingStatus: LoadingStatus = LoadingStatus.SUCCESS;
  @State bindFeedbackSheet: boolean = false;
  private displaySync = displaySync.create();
  private viewModel?: ComponentDetailPageVM;
  @State componentDetailState?: ComponentDetailState = this.viewModel?.getState();
  @State titleBarStyle: TitleBarStyleOptions = {
    scrollEffectOpts: {
      scrollEffectType: ScrollEffectType.COMMON_BLUR,
      enableScrollEffect: this.getEnableScrollEffect(),
    },
  };

  aboutToAppear(): void {
    if (HdsUtil.isSupportNewMaterialApi()) {
      this.titleBarStyle = {
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
        scrollEffectOpts: {
          enableScrollEffect: this.getEnableScrollEffect(),
          scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
            ScrollEffectType.COMMON_BLUR,
        },
      }
    }
  }

  handleBreakPointChange() {
    this.titleBarStyle.scrollEffectOpts = {
      enableScrollEffect: this.getEnableScrollEffect(),
    };
  }

  getEnableScrollEffect(): boolean {
    return new BreakpointType<boolean>({
      sm: false,
      md: true,
      lg: true,
    }).getValue(this.globalInfoModel.widthBreakpoint);
  }

  aboutToDisappear(): void {
    CommonConstants.PROMISE_WAIT(CommonConstants.REMOVE_DURATION).then(() => {
      this.componentDetailState?.recommends.forEach((item: RecommendData) => {
        WebUtil.removeNode(item.url);
      });
    });
  }

  handleOnReady(ctx: NavDestinationContext) {
    const params: ComponentDetailParams = ctx?.pathInfo?.param as ComponentDetailParams;
    this.componentName = params.title as string;
    this.componentId = Number(params.id);
    this.assignViewData(ctx?.pathStack);
  }

  @Builder
  DetailContentBuilder() {
    FeedbackSheet({
      bindFeedback: this.bindFeedbackSheet,
      feedbackInitParams: {
        domain: FeedbackDomain.COMPONENT,
        domainId: this.componentId,
        domainTitle: this.componentName,
        likeReasonsResource: $r('app.strarray.component_like_reason_list'),
        dislikeReasonsResource: $r('app.strarray.component_dislike_reason_list'),
      }
    })
    DetailContentView({
      componentDetailState: this.componentDetailState,
      componentName: this.componentName,
    })
      .layoutWeight(1)
  }

  @Builder
  ContentBuilder() {
    BaseDetailComponent({
      detailContentView: () => {
        this.DetailContentBuilder()
      },
      reloadData: () => {
        this.assignViewData();
      },
      loadingStatus: this.loadingStatus,
    })
      .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
  }

  build() {
    HdsNavDestination() {
      this.ContentBuilder()
    }
    .hideBackButton(false)
    .backgroundColor($r('sys.color.background_secondary'))
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .titleBar({
      style: this.titleBarStyle,
      content: {
        title: { mainTitle: this.componentDetailState?.topNavigationData.title || '' },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.square_and_pencil'),
              isEnabled: true,
              action: () => {
                this.bindFeedbackSheet = true;
              }
            }
          }]
        },
      }
    })
    .systemBarStyle({
      statusBarContentColor: this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
        StatusBarColorType.WHITE : StatusBarColorType.BLACK
    }, {
      statusBarContentColor: this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
        StatusBarColorType.WHITE : StatusBarColorType.BLACK
    })
    .onDisAppear(() => {
      this.release();
    })
    .onBackPressed(() => {
      if (!this.componentDetailState?.backPressed) {
        this.viewModel?.sendEvent(new ChangeBackPressed(true));
        this.viewModel?.sendEvent(new BackPage());
      }
      return true;
    })
    .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
  }

  release() {
    this.displaySync.stop();
    this.displaySync.off('frame');
  }

  assignViewData(pathStack?: NavPathStack) {
    this.viewModel = ComponentDetailManager.getInstance().getDetailViewModel(this.componentName);
    if (!this.viewModel) {
      this.viewModel = new ComponentDetailPageVM(this.componentName);
    }
    if (pathStack) {
      this.viewModel?.sendEvent(new AssignPathStackEvent(pathStack));
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
      if (this.componentDetailState?.loadingStatus !== LoadingStatus.SUCCESS) {
        this.loadingStatus = this.componentDetailState?.loadingStatus ?? LoadingStatus.FAILED;
        return;
      }
      this.displaySync.on('frame', () => {
        const promise = this.viewModel?.sendEvent(new ComponentDetailEvent(eventList[frameCount]));
        this.componentDetailState = this.viewModel?.getState();
        this.viewModel?.sendEvent(new ChangeBackPressed(false));
        frameCount++;
        if (frameCount >= eventCount) {
          promise?.then(() => {
            this.displaySync.stop();
            this.displaySync.off('frame');
          }).catch(() => {
            this.displaySync.stop();
            this.displaySync.off('frame');
          });
        }
      });
      this.displaySync.start();
    })
      .catch(() => {
        this.loadingStatus = this.viewModel?.getState().loadingStatus ?? LoadingStatus.FAILED;
      });
  }
}

@Builder
export function ComponentDetailBuilder() {
  ComponentDetailView()
}