/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { webview } from '@kit.ArkWeb';
import {
  CommonConstants,
  GlobalInfoModel,
  LoadingStatus,
  Logger,
  NativeActionData,
  StorageKey,
  WebSheetBuilder,
  WebUtil,
} from '@ohos/common';
import { BaseDetailComponent } from '@ohos/commonbusiness';
import { ArticleDetailViewModel } from '../viewmodel/ArticleDetailViewModel';
import { ExplorationDetailState } from '../viewmodel/ExplorationDetailState';

const NO_NETWORK_CODE = -106;
const TAG = '[ArticleWebComponent]';

@Component
export struct ArticleWebComponent {
  webController: webview.WebviewController = new webview.WebviewController();
  @Prop @Require viewModel: ArticleDetailViewModel;
  @Prop @Require detailsUrl: string;
  @Prop tabViewType: number = -1;
  @Link loadingStatus: LoadingStatus;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @Link bindSheetShow: boolean;
  @Link bindSheetSrc: string;
  @State detailState: ExplorationDetailState = this.viewModel.getState();
  @State isBlur: boolean = false;
  @State title: string = '';
  @Link webUrlType: number;
  bindScroller?: Scroller;

  @Builder
  WebContentBuilder() {
    Stack() {
      Scroll(this.bindScroller).zIndex(-1)
      Scroll() {
        Web({ src: this.detailsUrl, controller: this.webController })
          .zoomAccess(false)
          .fileAccess(false)
          .mixedMode(MixedMode.None)
          .verticalScrollBarAccess(false)
          .horizontalScrollBarAccess(false)
          .imageAccess(true)
          .cacheMode(CacheMode.Default)
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .javaScriptProxy({
            object: new NativeActionData(this.detailsUrl),
            name: 'nativeActionData',
            methodList: ['webSheet', 'jumpPage', 'imagePreviewChanged'],
            controller: this.webController,
            permission: WebUtil.getJsPermission(),
          })
          .geolocationAccess(false)
          .backgroundColor($r('sys.color.background_secondary'))
          .overScrollMode(OverScrollMode.ALWAYS)
          .darkMode(WebDarkMode.Auto)
          .forceDarkAccess(true)
          .allowDrop(null)
          .onPageVisible(() => {
            if (this.loadingStatus !== LoadingStatus.NO_NETWORK) {
              this.loadingStatus = LoadingStatus.SUCCESS;
            }
          })
          .onErrorReceive((event: OnErrorReceiveEvent) => {
            const isMainFrame: boolean = event?.request?.isMainFrame();
            const errCode: number = event?.error?.getErrorCode();
            if (isMainFrame && errCode === NO_NETWORK_CODE) {
              this.loadingStatus = LoadingStatus.NO_NETWORK;
            }
            Logger.error(TAG, `onErrorReceive.url: ${this.detailsUrl}; isMainFrame: ${isMainFrame}; code: ${errCode}`);
          })
          .onLoadIntercept((event: OnLoadInterceptEvent) => {
            return WebUtil.handleLoadIntercept(event);
          })
          .onConsole((event: OnConsoleEvent) => {
            Logger.error(TAG, event.message.getMessage())
            return false;
          })
          .onSslErrorEventReceive((event) => {
            Logger.error(TAG, `SSL checked failed, error: ${event.error.toString()}`);
            event.handler.handleCancel();
          })
          .onControllerAttached(() => {
            WebUtil.setWebController(this.detailsUrl, this.webController);
            // Setting the local file path that allows cross-domain access.
            const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
            const context: Context = uiContext?.getHostContext() as Context;
            try {
              this.webController.setPathAllowingUniversalAccess([context?.resourceDir]);
            } catch (error) {
              Logger.error(TAG, `setPathAllowingUniversalAccess failed, error: ${error.message}`);
            }
          })
          .onScroll((event) => {
            this.bindScroller?.scrollTo({ xOffset: event.xOffset, yOffset: event.yOffset });
          })
          .width('100%')
          .height('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .onReachStart(() => {
        this.bindScroller?.scrollEdge(Edge.Top);
      })
      .onReachEnd(() => {
        this.bindScroller?.scrollEdge(Edge.Bottom);
      })
    }
  }

  build() {
    BaseDetailComponent({
      detailContentView: () => {
        this.WebContentBuilder()
      },
      reloadData: () => {
        try {
          this.loadingStatus = LoadingStatus.LOADING;
          this.webController.refresh();
        } catch (error) {
          Logger.error(TAG, `Refresh failed.url: ${this.detailsUrl}`);
        }
      },
      loadingStatus: this.loadingStatus,
    })
      .backgroundColor(Color.Transparent)
      .width('100%')
      .height('100%')
      .bindSheet(this.bindSheetShow,
        WebSheetBuilder(this.bindSheetSrc, this.webUrlType), {
          title: { title: '' },
          preferType: SheetType.CENTER,
          height: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
            ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
              CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
          width: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? CommonConstants.SHEET_WIDTH_XL :
            undefined,
          onDisappear: () => {
            this.bindSheetShow = false;
          },
        })
  }
}