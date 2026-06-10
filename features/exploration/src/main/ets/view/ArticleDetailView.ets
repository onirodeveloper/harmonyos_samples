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

import { uniformTypeDescriptor } from '@kit.ArkData';
import { webview } from '@kit.ArkWeb';
import { curves } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import { hdsMaterial, HdsNavDestination, ScrollEffectType, TitleBarStyleOptions } from '@kit.UIDesignKit';
import {
  CommonConstants,
  ConfigMapKey,
  GlobalInfoModel,
  HdsUtil,
  LoadingStatus,
  Logger,
  ResourceUtil,
  ShareUtil,
  StatusBarColorType,
  StorageKey,
  WebUtil,
} from '@ohos/common';
import { ArticleWebComponent } from '../component/ArticleWebComponent';
import { DiscoverContent } from '../model/DiscoverData';
import {
  ArticleDetailViewModel,
  AssignPathStackParam,
  DetailParam,
  ExplorationDetailEventType,
  NativePageParam,
  PopParam,
} from '../viewmodel/ArticleDetailViewModel';
import type { ExplorationDetailState } from '../viewmodel/ExplorationDetailState';
import { DiscoveryConstant } from '../common/DiscoveryConstant';

@Builder
export function ArticleDetailViewBuilder() {
  ArticleDetailView()
}

@Builder
export function BannerDetailViewBuilder() {
  ArticleDetailView({ isBannerDetail: true })
}

const TAG = '[ArticleDetailView]';

@Component
struct ArticleDetailView {
  @Prop isBannerDetail?: boolean = false;
  @StorageProp(StorageKey.COLOR_MODE) systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  private viewModel: ArticleDetailViewModel = new ArticleDetailViewModel();
  private webController: webview.WebviewController = new webview.WebviewController();
  discoverContent: DiscoverContent = new DiscoverContent();
  private tabViewType: number = -1;
  private bindScroller: Scroller = new Scroller();
  private lastBackTs: number = 0;
  @State detailState: ExplorationDetailState = this.viewModel.getState();
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;
  @State isChangePage: boolean = true; // Check whether to set geometryTransition id.
  @State isPopTransition: boolean = false;
  @State titleBarStyle: TitleBarStyleOptions = {
    scrollEffectOpts: {
      scrollEffectType: ScrollEffectType.COMMON_BLUR,
      enableScrollEffect: true,
    },
    originalStyle: {
      contentStyle: {
        titleStyle: {
          mainTitleColor: Color.Transparent,
        },
        menuStyle: {
          iconColor: $r('sys.color.icon_primary'),
          backgroundColor: AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? Color.Transparent :
            $r('sys.color.comp_background_tertiary')
        }
      },
    },
  };
  @State bindSheetShow: boolean = false;
  @State bindSheetSrc: string = '';
  bindSheetSrcSet: Set<string> = new Set();
  @State webUrlType: number = 0;
  @State imagePreviewVisible: boolean = false;

  aboutToAppear(): void {
    if (HdsUtil.isSupportNewMaterialApi()) {
      this.titleBarStyle = {
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
            ScrollEffectType.COMMON_BLUR,
        },
        originalStyle: {
          contentStyle: {
            titleStyle: {
              mainTitleColor: Color.Transparent,
            }
          }
        }
      }
    }
  }

  aboutToDisappear(): void {
    try {
      this.bindSheetSrcSet.forEach((item: string) => {
        WebUtil.removeNode(item);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Web load data error. ${err?.code}, ${err.message}`);
    }
  }

  registerJsFunction() {
    WebUtil.setWebSheetAction(this.discoverContent.detailsUrl, (src: string, type: number) => {
      this.webUrlType = type;
      if (!this.bindSheetSrcSet.has(src)) {
        WebUtil.createWebNode(src, this.getUIContext(), NestedScrollMode.SELF_ONLY);
        this.bindSheetSrcSet.add(src);
      }
      this.bindSheetShow = true;
      this.bindSheetSrc = src;
    });
    WebUtil.setJumpPageAction(this.discoverContent.detailsUrl,
      (type: string, id: number, currentIndex?: number, title?: string) => {
        this.viewModel.sendEvent<NativePageParam>({
          type: ExplorationDetailEventType.JUMP_NATIVE_PAGE,
          param: {
            tabBarView: this.tabViewType,
            type,
            id,
            currentIndex,
            title,
          },
        });
      });
    WebUtil.setImagePreviewAction(this.discoverContent.detailsUrl, (isShown: boolean) => {
      this.imagePreviewVisible = isShown;
    });
  }

  checkPreview(method: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      this.webController = WebUtil.getWebController(this.discoverContent.detailsUrl)!;
      try {
        if (WebUtil.ARTICLE_WHITE_METHODS.indexOf(method) >= 0) {
          this.webController?.runJavaScriptExt(
            method,
            (error, result) => {
              if (error) {
                reject(`Run javascript error. Cause: ${error.message}`);
              }
              if (result) {
                const type = result.getType();
                if (type === webview.JsMessageType.BOOLEAN) {
                  resolve(result.getBoolean());
                } else {
                  reject(`CheckPreview error, type:${type}`);
                }
              }
            });
        } else {
          Logger.error(TAG, `Input method ${method} not in whitelist`);
        }
      } catch (error) {
        reject(`Run javascript failed error. Cause: ${error.message}`);
      }
    });
  }

  customBackPressed(): boolean {
    // Suppress repeated triggers occurring within 1 second
    const now = Date.now();
    if (now - this.lastBackTs < DiscoveryConstant.CLICK_TIME_INTERVAL_MS) {
      return true;
    }
    this.lastBackTs = now;
    if (this.loadingStatus === LoadingStatus.SUCCESS) {
      this.checkPreview('checkPreview()')
        .then((res) => {
          if (res) {
            const closePreviewMethod: string = 'closePreview()';
            if (WebUtil.ARTICLE_WHITE_METHODS.indexOf(closePreviewMethod) >= 0) {
              this.webController?.runJavaScript(closePreviewMethod)
                .catch((error: BusinessError) => {
                  Logger.error(TAG, `runJavaScript failed. Cause: ${error.message}`);
                });
            } else {
              Logger.error(TAG, `Input method ${closePreviewMethod} not in whitelist`);
            }
          } else {
            this.popAction(!this.isBannerDetail);
          }
        })
        .catch((error: string) => {
          Logger.error(TAG, `Run javascript error: ${error}`);
        })
    } else {
      this.popAction(!this.isBannerDetail);
    }
    return true;
  }

  popAction(isAnimation: boolean) {
    this.isPopTransition = true;
    this.isChangePage = true;
    if (this.isBannerDetail) {
      this.getUIContext().animateTo({
        curve: curves.interpolatingSpring(0, 1, 363, 38),
      }, () => {
        try {
          WebUtil.getWebController(this.discoverContent.detailsUrl)?.onInactive();
        } catch (error) {
          Logger.error(TAG, `WebController.onInactive failed. Cause message: ${error.message}`);
        } finally {
          this.viewModel.sendEvent<PopParam>({
            type: ExplorationDetailEventType.POP,
            param: { animation: isAnimation, tabBarView: this.tabViewType },
          });
        }
      });
    } else {
      this.viewModel.sendEvent<PopParam>({
        type: ExplorationDetailEventType.POP,
        param: { animation: isAnimation, tabBarView: this.tabViewType },
      });
      try {
        WebUtil.getWebController(this.discoverContent.detailsUrl)?.onInactive();
      } catch (error) {
        Logger.error(TAG, `WebController.onInactive failed. Cause message: ${error.message}`);
      }
    }
  }

  shareLink(): void {
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    const context = uiContext?.getHostContext();
    if (!uiContext || !context) {
      Logger.error(TAG, `Failed to jumpToBrowser. Cause uicontext or context is undefined.`);
      return;
    }

    ShareUtil.shareData({
      utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
      content: ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.DEVELOPER_URL) as string,
      title: this.discoverContent.title,
      description: this.discoverContent.desc
    });
  }

  handleOnReady(cxt: NavDestinationContext) {
    const params = cxt?.pathInfo?.param as Record<string, string | number | boolean>;
    this.discoverContent.id = params.id as number;
    this.discoverContent.detailsUrl = params.detailsUrl as string;
    this.discoverContent.title = params.title as string;
    this.discoverContent.desc = params.desc as string;
    this.tabViewType = (params.tabViewType ?? -1) as number;
    this.viewModel.sendEvent<AssignPathStackParam>({
      type: ExplorationDetailEventType.ASSIGN_PATH_STACK,
      param: {
        navPathStack: cxt?.pathStack
      }
    });
    this.viewModel.sendEvent<DetailParam>({
      type: ExplorationDetailEventType.GET_ARTICLE_DETAIL,
      param: {
        content: this.discoverContent,
        onBackClick: () => {
          this.customBackPressed?.();
        },
      },
    });
    if (!this.isBannerDetail) {
      CommonConstants.PROMISE_WAIT(CommonConstants.ANIMATION_DELAY).then(() => {
        this.loadingStatus = LoadingStatus.LOADING;
      });
    }
    this.registerJsFunction();
  }

  build() {
    HdsNavDestination() {
      ArticleWebComponent({
        bindScroller: this.bindScroller,
        viewModel: this.viewModel,
        bindSheetShow: this.bindSheetShow,
        bindSheetSrc: this.bindSheetSrc,
        webUrlType: this.webUrlType,
        detailsUrl: this.detailState.content.detailsUrl,
        tabViewType: this.tabViewType,
        loadingStatus: this.loadingStatus,
      })
        .geometryTransition(this.isBannerDetail && this.isChangePage ?
          CommonConstants.BANNER_GEOMETRY + this.tabViewType.toString() : '')
        .transition(this.isBannerDetail && this.isChangePage ? (this.isPopTransition ? TransitionEffect.OPACITY :
          TransitionEffect.OPACITY.animation({ duration: CommonConstants.TRANSITION_DURATION })) : undefined,
          this.isBannerDetail ? (transitionIn: boolean) => {
            if (transitionIn) {
              this.isChangePage = false;
              this.loadingStatus = LoadingStatus.LOADING;
            }
          } : undefined)
    }
    .titleBar({
      style: this.titleBarStyle,
      content: {
        title: {
          mainTitle: this.detailState.content.title
        },
        menu: {
          value: [{
            content: {
              icon: $r('sys.symbol.share'),
              isEnabled: true,
              action: () => {
                this.shareLink();
              }
            }
          }]
        }
      }
    })
    .bindToScrollable([this.bindScroller])
    .systemBarStyle({
      statusBarContentColor: this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
        StatusBarColorType.WHITE : StatusBarColorType.BLACK
    }, {
      statusBarContentColor: this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
        StatusBarColorType.WHITE : StatusBarColorType.BLACK
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .defaultFocus(true)
    .onReady((cxt: NavDestinationContext) => this.handleOnReady(cxt))
    .onBackPressed((): boolean => {
      return this.customBackPressed();
    })
    .backgroundColor(this.isBannerDetail ? Color.Transparent : $r('sys.color.background_secondary'))
    .hideTitleBar(this.imagePreviewVisible, true)
  }
}