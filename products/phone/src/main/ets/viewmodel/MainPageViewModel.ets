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
  PageEnum,
  StorageKey,
  WantParams,
} from '@ohos/common';
import { ArticleDetailParams, TabBarType } from '@ohos/commonbusiness';

export class MainPageViewModel extends BaseVM<BaseState> {
  public constructor() {
    super(new BaseState())
  }

  public sendEvent<T>(event: HomeEventParam<T>): number | void {
    if (event.type===HomeEventTypeEnum.JUMP_TO_PAGE) {
      return this.jumpToPage(event.param as WantParams);
    }
  }

  private jumpToPage(wantParams: WantParams): number {
    if (wantParams?.shortCutKey) {
      return this.navigateToModuleHome(wantParams.shortCutKey)
    } else if (wantParams?.cardFrom === FormCardEnum.ARTICLE_SERVICE_CARD) {
      if (wantParams?.articleInfo) {
        this.navigateToArticleDetail(wantParams.articleInfo);
      }
      return TabBarType.PRACTICE;
    } else if (wantParams?.cardFrom === FormCardEnum.LOCK_SCREEN_CARD ||
      wantParams?.cardFrom === FormCardEnum.LOCK_SCREEN_CARD_LG) {
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
      const globalInfoModel = AppStorage.get<GlobalInfoModel>(StorageKey.GLOBAL_INFO)
      const pageContext = globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        AppStorage.get<PageContext>(StorageKey.EXPLORATION_PAGE_CONTEXT) :
        AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
      const articleParams: ArticleDetailParams = {
        id: articleInfo.id,
        isArticle: articleInfo.isArticle ?? true,
        title: articleInfo.title,
        detailsUrl: articleInfo.detailsUrl,
      }
      pageContext?.openPage({
        routerName: PageEnum.ARTICLE_DETAIL_VIEW,
        param: articleParams,
      })
    }
  }
}

export interface HomeEventParam<T> {
  type: HomeEventTypeEnum,
  param?: T,
}

export enum HomeEventTypeEnum {
  JUMP_TO_PAGE = 'jumpToPage',
}

enum ShortCutKey {
  COMPONENT_LIST = 'ComponentListPage',
  SAMPLE_LIST = 'SampleListPage',
  ARTICLE_LIST = 'ArticleListPage',
}