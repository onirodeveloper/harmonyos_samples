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
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import {
  BreakpointType,
  CommonConstants,
  FeedbackDomain,
  FeedbackSheet,
  GlobalInfoModel,
  LoadingStatus,
  Logger,
  StorageKey,
  TopNavigationView,
  VersionUtil,
  WebUtil,
  WindowUtil,
} from '@ohos/common';
import { BaseDetailComponent, CardTypeEnum, ComponentDetailParams } from '@ohos/commonbusiness';
import {
  AssignPathStackEvent,
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

const TAG = '[ComponentDetailView]';

@Component({ freezeWhenInactive: true })
export struct ComponentDetailView {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @StorageLink(StorageKey.WEB_LOADING) @Watch('sendCodeToWeb') webIsLoading: boolean = false;
  @Prop componentName: string = '';
  @Prop componentId: number = 0;
  @Prop contentType: CardTypeEnum = CardTypeEnum.COMPONENT;
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;
  @State bindFeedbackSheet: boolean = false;
  private displaySync = displaySync.create();
  private viewModel?: ComponentDetailPageVM;
  @State componentDetailState?: ComponentDetailState = this.viewModel?.getState();

  aboutToAppear(): void {
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    WindowUtil.updateStatusBarColor(isSystemDark);
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
    this.componentName = params.componentName as string;
    this.componentId = Number(params.id);
    this.contentType = params.contentType;
    CommonConstants.PROMISE_WAIT(500).then(() => {
      this.assignViewData(ctx?.pathStack);
    });
  }

  @Builder
  DetailContentBuilder() {
    FeedbackSheet({
      bindFeedback: this.bindFeedbackSheet,
      feedbackInitParams: {
        uid: '1',
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
      contentType: this.contentType,
    })
      .layoutWeight(1)
  }

  @Builder
  TopTitleViewBuilder() {
    TopNavigationView({
      topNavigationData: this.componentDetailState?.topNavigationData,
      menuView: () => {
        this.TopNavigationMenu();
      }
    })
  }

  @Builder
  ContentBuilder() {
    BaseDetailComponent({
      detailContentView: () => {
        this.DetailContentBuilder()
      },
      topTitleView: () => {
        if (!VersionUtil.canUseHds()) {
          this.TopTitleViewBuilder()
        }
      },
      reloadData: () => {
        this.assignViewData();
      },
      loadingStatus: this.loadingStatus,
    })
      .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
  }

  @Builder
  TopNavigationMenu() {
    Button() {
      SymbolGlyph($r('sys.symbol.square_and_pencil'))
        .fontColor([$r('sys.color.icon_primary')])
        .fontSize($r('sys.float.Title_M'))
    }
    .width($r('app.float.feedback_sheet_button_size'))
    .height($r('app.float.feedback_sheet_button_size'))
    .aspectRatio(1)
    .backgroundColor(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? Color.Transparent :
      $r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.bindFeedbackSheet = true;
    })
    .margin({
      right: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        $r('app.float.feedback_right_padding_xl') : 0
    })
  }

  build() {
    if (VersionUtil.canUseHds()) {
      HdsNavDestination() {
        this.ContentBuilder()
      }
      .hideBackButton(false)
      .backgroundColor($r('sys.color.background_secondary'))
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
      .titleBar({
        avoidLayoutSafeArea: true,
        style: {
          scrollEffectOpts: {
            enableScrollEffect: new BreakpointType<boolean>({
              sm: false,
              md: true,
              lg: true,
            }).getValue(this.globalInfoModel.widthBreakpoint),
          },
        },
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
      .onDisAppear(() => {
        this.release();
      })
      .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
    } else {
      NavDestination() {
        this.ContentBuilder()
      }
      .hideTitleBar(true)
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .onDisAppear(() => {
        this.release();
      })
      .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
    }
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
      this.loadingStatus = LoadingStatus.LOADING;
      this.displaySync.on('frame', () => {
        const promise = this.viewModel?.sendEvent(new ComponentDetailEvent(eventList[frameCount]));
        this.componentDetailState = this.viewModel?.getState();
        frameCount++;
        if (frameCount >= eventCount) {
          promise?.then(() => {
            this.displaySync.stop();
            this.displaySync.off('frame');
            this.refreshCodePreviewWeb();
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

  refreshCodePreviewWeb() {
    this.webIsLoading = true;
    try {
      WebUtil.getWebController(WebUtil.getComponentCodeUrl())?.refresh();
    } catch {
      Logger.error(TAG, `refreshCodePreviewWeb failed.`);
    }
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