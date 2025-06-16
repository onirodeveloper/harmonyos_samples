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

import { curves } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { CommonConstants, LoadingStatus, Logger, WebUtil } from '@ohos/common';
import { ArticleWebComponent } from '../component/ArticleWebComponent';
import { DiscoverContent } from '../model/DiscoverData';
import {
  ArticleDetailViewModel,
  DetailParam,
  ExplorationDetailEventType,
  PopParam,
} from '../viewmodel/ArticleDetailViewModel';
import type { ExplorationDetailState } from '../viewmodel/ExplorationDetailState';

@Builder
export function BannerDetailViewBuilder() {
  BannerDetailView()
}

const TAG = '[BannerDetailView]';

@Component
struct BannerDetailView {
  viewModel: ArticleDetailViewModel = new ArticleDetailViewModel();
  webController: webview.WebviewController = new webview.WebviewController();
  tabViewType: number = -1;
  discoverContent: DiscoverContent = new DiscoverContent();
  @State animationDelay: boolean = false;
  @State detailState: ExplorationDetailState = this.viewModel.getState();
  @State isChangePage: boolean = true; // Check whether to set geometryTransition id.
  @State isPopTransition: boolean = false;
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;

  checkPreview(method: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      this.webController = WebUtil.getWebController(this.discoverContent.detailsUrl)!;
      try {
        if (WebUtil.ARTICLE_WHITE_METHODS.indexOf(method) >= 0) {
          this.webController.runJavaScriptExt(
            method,
            (error, result) => {
              if (error) {
                reject(`Run javascript error. ${JSON.stringify(error)}`);
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
        reject(`Run javascript failed error.${JSON.stringify(error)}`);
      }
    });
  }

  customBackPressed(): boolean {
    this.checkPreview('checkPreview()')
      .then((res) => {
        if (res) {
          const closePreviewMethod: string = 'closePreview()';
          if (WebUtil.ARTICLE_WHITE_METHODS.indexOf(closePreviewMethod) >= 0) {
            this.webController.runJavaScript(closePreviewMethod);
          } else {
            Logger.error(TAG, `Input method ${closePreviewMethod} not in whitelist`);
          }
        } else {
          this.popAction(false);
        }
      })
      .catch((error: string) => {
        Logger.error(TAG, `Run javascript error: ${error}`);
        this.popAction(false);
      })
    return true;
  }

  popAction(isAnimation: boolean) {
    this.isPopTransition = true;
    this.isChangePage = true;
    animateTo({
      curve: curves.interpolatingSpring(0, 1, 363, 38),
    }, () => {
      WebUtil.getWebController(this.discoverContent.detailsUrl)?.onInactive();
      this.viewModel.sendEvent<PopParam>({
        type: ExplorationDetailEventType.POP,
        param: { animation: isAnimation, tabBarView: this.tabViewType },
      });
    });
  }

  build() {
    NavDestination() {
      ArticleWebComponent({
        viewModel: this.viewModel,
        detailsUrl: this.detailState.content.detailsUrl,
        tabViewType: this.tabViewType,
        loadingStatus: this.loadingStatus,
      })
        .geometryTransition(this.isChangePage ? CommonConstants.BANNER_GEOMETRY + this.tabViewType.toString() : '')
        .transition(this.isChangePage ? (this.isPopTransition ? TransitionEffect.OPACITY :
        TransitionEffect.OPACITY.animation({ duration: CommonConstants.TRANSITION_DURATION })) : undefined,
          (transitionIn: boolean) => {
            if (transitionIn) {
              this.isChangePage = false;
              this.loadingStatus = LoadingStatus.LOADING;
            }
          })
    }
    .defaultFocus(true)
    .onReady((cxt: NavDestinationContext) => {
      const params = cxt.pathInfo.param as Record<string, string | number | boolean>;
      this.discoverContent.id = params.id as number;
      this.discoverContent.detailsUrl = params.detailsUrl as string;
      this.discoverContent.title = params.title as string;
      this.tabViewType = params.tabViewType as number;
      this.viewModel.sendEvent<DetailParam>({
        type: ExplorationDetailEventType.GET_ARTICLE_DETAIL,
        param: {
          content: this.discoverContent,
          onBackClick: () => {
            this.customBackPressed?.();
          },
        },
      });
    })
    .hideTitleBar(true)
    .onBackPressed((): boolean => {
      return this.customBackPressed();
    })
    .backgroundColor(Color.Transparent)
  }
}