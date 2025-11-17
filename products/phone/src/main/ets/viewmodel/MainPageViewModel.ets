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
  ArticleListItem,
  BaseState,
  BaseVM,
  FormCardEnum,
  GlobalInfoModel,
  PageContext,
  StorageKey,
  WantParams,
} from '@ohos/common';
import { ArticleDetailParams, TabBarType } from '@ohos/commonbusiness';

export class MainPageViewModel extends BaseVM<BaseState> {
  private globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;

  public constructor() {
    super(new BaseState())
  }

  public sendEvent(event: JumpToPageEvent): number {
    if (event.wantParams.shortCutKey) {
      return this.navigateToModuleHome(event.wantParams.shortCutKey)
    } else if (event.wantParams.cardFrom === FormCardEnum.ARTICLE_SERVICE_CARD) {
      this.navigateToArticleDetail(event.wantParams.articleInfo);
      return TabBarType.PRACTICE;
    } else if (event.wantParams.cardFrom === FormCardEnum.LOCK_SCREEN_CARD ||
      event.wantParams.cardFrom === FormCardEnum.LOCK_SCREEN_CARD_LG) {
      return TabBarType.HOME;
    }
    return TabBarType.HOME;
  }

  private navigateToModuleHome(shortCutKey: string): number {
    switch (shortCutKey) {
      case ShortCutKey.COMPONENT_LIST:
        return TabBarType.HOME;
      case ShortCutKey.SAMPLE_LIST:
        return TabBarType.SAMPLE;
      case ShortCutKey.ARTICLE_LIST:
        return TabBarType.PRACTICE;
      default:
        return TabBarType.HOME;
    }
  }

  private navigateToArticleDetail(articleInfo?: ArticleListItem) {
    if (articleInfo) {
      const pageContext: PageContext | undefined = this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        AppStorage.get(StorageKey.EXPLORATION_PAGE_CONTEXT) : AppStorage.get(StorageKey.HOME_PAGE_CONTEXT);
      const articleParams: ArticleDetailParams = {
        id: articleInfo.id,
        isArticle: articleInfo.isArticle ?? true,
        title: articleInfo.title,
        detailsUrl: articleInfo.detailsUrl
      }
      pageContext?.openPage({
        routerName: 'ArticleDetailView',
        param: articleParams,
      })
    }
  }
}

export class JumpToPageEvent {
  public readonly wantParams: WantParams;

  public constructor(wantParams: WantParams) {
    this.wantParams = wantParams;
  }
}

enum ShortCutKey {
  COMPONENT_LIST = 'ComponentListPage',
  SAMPLE_LIST = 'SampleListPage',
  ARTICLE_LIST = 'ArticleListPage',
}