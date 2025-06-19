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
export function ArticleDetailViewBuilder() {
  ArticleDetailView()
}

const TAG = '[ArticleDetailView]';

@Component
struct ArticleDetailView {
  viewModel: ArticleDetailViewModel = new ArticleDetailViewModel();
  webController: webview.WebviewController = new webview.WebviewController();
  discoverContent: DiscoverContent = new DiscoverContent();
  @State detailState: ExplorationDetailState = this.viewModel.getState();
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
          this.popAction(true);
        }
      })
      .catch((error: string) => {
        Logger.error(TAG, `Run javascript error: ${error}`);
        this.popAction(true);
      })
    return true;
  }

  popAction(isAnimation: boolean) {
    this.webController.onInactive();
    this.viewModel.sendEvent<PopParam>({
      type: ExplorationDetailEventType.POP,
      param: { animation: isAnimation, tabBarView: -1 },
    });
  }

  build() {
    NavDestination() {
      ArticleWebComponent({
        viewModel: this.viewModel,
        detailsUrl: this.detailState.content.detailsUrl,
        tabViewType: -1,
        loadingStatus: this.loadingStatus,
      })
    }
    .defaultFocus(true)
    .onReady((cxt: NavDestinationContext) => {
      const params = cxt.pathInfo.param as Record<string, string | number | boolean>;
      this.discoverContent.id = params.id as number;
      this.discoverContent.detailsUrl = params.detailsUrl as string;
      this.discoverContent.title = params.title as string;
      this.viewModel.sendEvent<DetailParam>({
        type: ExplorationDetailEventType.GET_ARTICLE_DETAIL,
        param: {
          content: this.discoverContent,
          onBackClick: () => {
            this.customBackPressed?.();
          },
        },
      });
      CommonConstants.PROMISE_WAIT(CommonConstants.ANIMATION_DELAY).then(() => {
        this.loadingStatus = LoadingStatus.LOADING;
      });
    })
    .hideTitleBar(true)
    .onBackPressed((): boolean => {
      return this.customBackPressed();
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}