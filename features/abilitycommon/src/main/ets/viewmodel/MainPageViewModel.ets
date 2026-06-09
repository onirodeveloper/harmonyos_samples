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
  CommonConstants,
  ConfigMapKey,
  FormCardEnum,
  InteractionTypeEnum,
  PageContext,
  PageEnum,
  ReferTypeEnum,
  ResourceUtil,
  StorageKey,
  TrackEventType,
  TrackManager,
  TrackServiceData,
  WantParams,
} from '@ohos/common';
import {
  ArticleDetailParams,
  CardTypeEnum,
  ComponentDetailParams,
  SampleDetailParams,
  TabBarType
} from '@ohos/commonbusiness';

export class MainPageViewModel extends BaseVM<BaseState> {

  public constructor() {
    super(new BaseState())
  }

  public sendEvent<T>(event: HomeEventParam<T>): number | void {
    if (event.type === HomeEventTypeEnum.JUMP_TO_PAGE) {
      return this.jumpToPage(event.param as WantParams);
    }
  }

  private jumpToPage(wantParams: WantParams): number {
    if (wantParams?.shortCutKey) {
      return this.navigateToModuleHome(wantParams.shortCutKey)
    } else if (wantParams?.pushMessage) {
      return this.navigateToModuleDetail(wantParams);
    } else if (wantParams?.cardFrom === FormCardEnum.ARTICLE_SERVICE_CARD) {
      if (wantParams?.articleInfo) {
        this.navigateToArticleDetail(wantParams.articleInfo);
      }
      return TabBarType.PRACTICE;
    } else if (wantParams?.cardFrom === FormCardEnum.LOCK_SCREEN_CARD ||
      wantParams?.cardFrom === FormCardEnum.LOCK_SCREEN_CARD_LG) {
      return TabBarType.HOME;
    } else if (wantParams?.fromIntent) {
      return this.navigateToModuleDetail(wantParams);
    }
    return TabBarType.HOME;
  }

  private navigateToModuleHome(shortCutKey: string): TabBarType {
    switch (shortCutKey) {
      case ShortCutKey.COMPONENT_LIST:
        return TabBarType.HOME;
      case ShortCutKey.SAMPLE_LIST:
        return TabBarType.SAMPLE;
      case ShortCutKey.ARTICLE_LIST:
        return TabBarType.PRACTICE;
      case ShortCutKey.MINE_PAGE:
        return TabBarType.MINE;
      default:
        return TabBarType.HOME;
    }
  }

  private navigateToArticleDetail(articleInfo?: ArticleListItem) {
    const uiContext: UIContext | undefined = AppStorage.get(StorageKey.UI_CONTEXT);
    let contentCenterUrl: string = '';
    if (uiContext) {
      const context: Context | undefined = uiContext.getHostContext();
      if (context) {
        contentCenterUrl = ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.CONTENT_CENTER) as string;
      }
    }
    if (articleInfo) {
      const pageContext = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
        AppStorage.get<PageContext>(StorageKey.EXPLORATION_PAGE_CONTEXT) :
        AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
      const articleParams: ArticleDetailParams = {
        id: articleInfo.id,
        isArticle: articleInfo.isArticle ?? true,
        title: articleInfo.title,
        desc: articleInfo.desc,
        detailsUrl: contentCenterUrl + articleInfo.detailsUrl,
        interactionType: InteractionTypeEnum.ARTICLE,
      }
      pageContext?.openPage({
        routerName: PageEnum.ARTICLE_DETAIL_VIEW,
        param: articleParams,
      })
    }
  }

  private reportTrackData(interactionType: InteractionTypeEnum, wantParams: WantParams): void {
    // Push track report.
    TrackManager.getInstance().reportData({
      referType: ReferTypeEnum.PUSH,
      eventType: TrackEventType.CLICK,
      referSourceId: wantParams.messageID,
      interactionType,
      interactionContent: wantParams.title,
      pushMessageTitle: wantParams.messageTitle,
    } as TrackServiceData);
  }

  private navigateToModuleDetail(wantParams: WantParams): TabBarType {
    let name: PageEnum = PageEnum.COMPONENT_DETAIL_VIEW;
    let param: ComponentDetailParams | SampleDetailParams | ArticleDetailParams | undefined;
    let tabIndex: TabBarType = TabBarType.HOME;
    let interactionType: InteractionTypeEnum = InteractionTypeEnum.COMPONENT;
    const pageContext = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
      AppStorage.get<PageContext>(StorageKey.EXPLORATION_PAGE_CONTEXT) :
      AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    if (!wantParams) {
      return tabIndex;
    }
    const contentType: CardTypeEnum = wantParams.moduleType ?? CardTypeEnum.UNKNOWN;
    if (contentType === CardTypeEnum.COMPONENT) {
      interactionType = InteractionTypeEnum.COMPONENT;
      name = PageEnum.COMPONENT_DETAIL_VIEW;
      param = { title: wantParams.title, id: wantParams.id, interactionType } as ComponentDetailParams;
    } else if (contentType === CardTypeEnum.SAMPLE) {
      interactionType = InteractionTypeEnum.SAMPLE;
      name = PageEnum.SAMPLE_DETAIL_VIEW;
      param = {
        currentIndex: wantParams.currentIndex ?? 0,
        cardId: wantParams.cardId,
        id: wantParams.id,
        interactionType,
        unionId: wantParams.unionId,
        categoryName: wantParams.categoryName,
      } as SampleDetailParams;
      tabIndex = TabBarType.SAMPLE;
    } else if (contentType === CardTypeEnum.ARTICLE) {
      interactionType = InteractionTypeEnum.ARTICLE;
      name = PageEnum.ARTICLE_DETAIL_VIEW;
      param = {
        id: wantParams.id,
        title: wantParams.title,
        isArticle: true,
        detailsUrl: wantParams.detailsUrl || '',
        interactionType,
      } as ArticleDetailParams;
      tabIndex = TabBarType.PRACTICE;
    }
    // In case of router to component detail view by cold pull, the web node hasn't prepare well, so delay it.
    CommonConstants.PROMISE_WAIT(0).then(() => {
      pageContext?.openPage({
        routerName: name,
        param,
      });
    });
    this.reportTrackData(interactionType, wantParams);
    return tabIndex;
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
  MINE_PAGE = 'MinePage',
}