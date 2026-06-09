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

import { UIContext } from '@kit.ArkUI';
import {
  BaseVM,
  FileUtil,
  InteractionTypeEnum,
  LoadingStatus,
  Logger,
  PageEnum,
  StorageKey,
  UrlUtil,
} from '@ohos/common';
import { ComponentDetailParams, SampleDetailParams } from '@ohos/commonbusiness';
import type { DiscoverContent } from '../model/DiscoverData';
import { ExplorationDetailState } from './ExplorationDetailState';

const TAG: string = '[ArticleDetailViewModel]';

export class ArticleDetailViewModel extends BaseVM<ExplorationDetailState> {
  private currentPathStack?: NavPathStack;

  public constructor() {
    super(new ExplorationDetailState());
  }

  sendEvent<T>(eventParam: ExplorationDetailEventParam<T>): Promise<void> | void {
    if (eventParam.type === ExplorationDetailEventType.GET_ARTICLE_DETAIL) {
      return this.getArticleDetail(eventParam.param as DetailParam);
    } else if (eventParam.type === ExplorationDetailEventType.POP) {
      const param = eventParam.param as PopParam;
      return this.pop(param.animation);
    } else if (eventParam.type === ExplorationDetailEventType.JUMP_NATIVE_PAGE) {
      return this.jumpNativePage(eventParam.param as NativePageParam);
    } else if (eventParam.type === ExplorationDetailEventType.ASSIGN_PATH_STACK) {
      this.currentPathStack = (eventParam.param as AssignPathStackParam).navPathStack;
      return;
    }
    throw new Error('Method not implemented.');
  }

  private getArticleDetail(detailParam: DetailParam): Promise<void> {
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    this.state.content = detailParam.content;
    const detailUrl: string = detailParam.content.detailsUrl;
    if (UrlUtil.isNetUrl(detailUrl)) {
      this.state.content.detailsUrl = detailUrl;
    } else {
      if (FileUtil.isInvalidPath(detailUrl)) {
        Logger.error(TAG, `getArticleDetail failed. Cause: detailUrl is invalid.`);
        return Promise.reject();
      }
      const uiContext: UIContext | undefined = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
      const context = uiContext?.getHostContext();
      if (context) {
        this.state.content.detailsUrl = `${context.resourceDir}/${detailUrl}`;
      } else {
        Logger.error(TAG, `getArticleDetail failed. Cause: uicontext is null`);
        return Promise.reject();
      }
    }
    this.state.topNavigationData.onBackClick = detailParam.onBackClick;
    this.state.topNavigationData.isFullScreen = true;
    return Promise.resolve();
  }

  private pop(animated: boolean = true): void {
    this.currentPathStack?.pop(animated);
  }

  private jumpNativePage(param: NativePageParam): void {
    this.currentPathStack?.pushPath({
      name: param.type === 'component' ? PageEnum.COMPONENT_DETAIL_VIEW : PageEnum.SAMPLE_DETAIL_VIEW,
      param: param.type === 'component' ?
        {
          title: param.title,
          id: param.id,
          interactionType: InteractionTypeEnum.COMPONENT,
        } as ComponentDetailParams :
        {
          currentIndex: param.currentIndex,
          cardId: param.id,
          interactionType: InteractionTypeEnum.SAMPLE,
        } as SampleDetailParams,
    }, true);
  }
}

export enum ExplorationDetailEventType {
  GET_ARTICLE_DETAIL = 'getArticleDetail',
  POP = 'pop',
  HANDLE_TITLE_EFFECT = 'handleTitleEffect',
  JUMP_NATIVE_PAGE = 'jumpNativePage',
  ASSIGN_PATH_STACK = 'AssignPathStackEvent',
  CHANGE_TITLE_BAR_STYLE = 'changeTitleBarStyle',
}

export interface ExplorationDetailEventParam<T> {
  type: ExplorationDetailEventType;
  param: T;
}

export interface DetailParam {
  content: DiscoverContent;
  onBackClick: () => void;
}

export interface PopParam {
  animation: boolean;
  tabBarView: number;
}

export interface NativePageParam {
  tabBarView: number;
  type: string;
  id: number;
  currentIndex?: number;
  title?: string;
}

export interface AssignPathStackParam {
  navPathStack: NavPathStack;
}