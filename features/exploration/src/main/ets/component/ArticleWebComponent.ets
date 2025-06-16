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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { webview } from '@kit.ArkWeb';
import type { BusinessError } from '@kit.BasicServicesKit';
import {
  BreakpointTypeEnum,
  CommonConstants,
  GlobalInfoModel,
  javascriptProxyPermission,
  LoadingStatus,
  Logger,
  NativeActionData,
  TopNavigationView,
  WebSheetBuilder,
  WebUtil,
  WindowUtil
} from '@ohos/common';
import { BaseDetailComponent } from '@ohos/commonbusiness';
import {
  ArticleDetailViewModel,
  ExplorationDetailEventType,
  NativePageParam,
} from '../viewmodel/ArticleDetailViewModel';
import { ExplorationDetailState } from '../viewmodel/ExplorationDetailState';

const TAG = '[ArticleWebComponent]';

@Component
export struct ArticleWebComponent {
  webController: webview.WebviewController = new webview.WebviewController();
  @Prop @Require viewModel: ArticleDetailViewModel;
  @Prop @Require detailsUrl: string;
  @Prop tabViewType: number = -1;
  @Link loadingStatus: LoadingStatus;
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @StorageProp('systemColorMode') @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get('systemColorMode')!;
  @State bindSheetShow: boolean = false;
  @State bindSheetSrc: string = '';
  @State detailState: ExplorationDetailState = this.viewModel.getState();
  @State isBlur: boolean = false;
  @State title: string = '';
  bindSheetSrcSet: Set<string> = new Set();
  webUrlType: number = 0;

  aboutToAppear(): void {
    this.handleColorModeChange();
    this.registerJsFunction();
  }

  aboutToDisappear(): void {
    try {
      this.bindSheetSrcSet.forEach((item: string) => {
        WebUtil.removeNode(item);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Web load Data error. ${err.code}, ${err.message}`);
    }
  }

  handleWebScroll(yOffset: number) {
    this.title = yOffset > CommonConstants.NAVIGATION_HEIGHT ? this.detailState.content.title : '';
    this.isBlur = yOffset > CommonConstants.SPACE_12;
  }

  handleColorModeChange() {
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    WindowUtil.updateStatusBarColor(getContext(this), isSystemDark);
  }

  registerJsFunction() {
    WebUtil.setWebSheetAction(this.detailsUrl, (src: string, type: number) => {
      this.webUrlType = type;
      if (!this.bindSheetSrcSet.has(src)) {
        WebUtil.createWebNode(src, this.getUIContext(), NestedScrollMode.SELF_ONLY);
        this.bindSheetSrcSet.add(src);
      }
      this.bindSheetShow = true;
      this.bindSheetSrc = src;
    });
    WebUtil.setJumpPageAction(this.detailsUrl,
      (type: string, id: number, currentIndex?: number, componentName?: string) => {
        this.viewModel.sendEvent<NativePageParam>({
          type: ExplorationDetailEventType.JUMP_NATIVE_PAGE,
          param: {
            tabBarView: this.tabViewType,
            type,
            id,
            currentIndex,
            componentName,
          },
        });
      })
  }

  @Builder
  WebContentBuilder() {
    Web({ src: this.detailsUrl, controller: this.webController })
      .zoomAccess(false)
      .fileAccess(true)
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
        methodList: ['webSheet', 'jumpPage'],
        controller: this.webController,
        permission: javascriptProxyPermission,
      })
      .geolocationAccess(false)
      .backgroundColor($r('sys.color.background_secondary'))
      .overScrollMode(OverScrollMode.ALWAYS)
      .darkMode(WebDarkMode.Auto)
      .forceDarkAccess(true)
      .allowDrop(null)
      .onPageEnd(() => {
        this.loadingStatus = LoadingStatus.SUCCESS;
        WebUtil.setTrustList(this.detailsUrl);
      })
      .onLoadIntercept((event: OnLoadInterceptEvent) => {
        const tempUrl = event.data.getRequestUrl();
        return WebUtil.checkUrl(tempUrl);
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
        this.webController.setPathAllowingUniversalAccess([getContext().resourceDir]);
      })
      .onScroll((event) => {
        this.handleWebScroll(event.yOffset);
      })
      .width('100%')
      .height('100%')
  }

  @Builder
  TopTitleViewBuilder() {
    TopNavigationView({
      topNavigationData: {
        title: this.title,
        isBlur: this.isBlur,
        isFullScreen: true,
        onBackClick: () => {
          this.detailState.topNavigationData.onBackClick?.();
        }
      },
    })
  }

  build() {
    BaseDetailComponent({
      detailContentView: () => {
        this.WebContentBuilder()
      },
      topTitleView: () => {
        this.TopTitleViewBuilder()
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
          height: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
            ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
            CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
          width: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? CommonConstants.SHEET_WIDTH_XL :
            undefined,
          onDisappear: () => {
            this.bindSheetShow = false;
          },
        })
  }
}