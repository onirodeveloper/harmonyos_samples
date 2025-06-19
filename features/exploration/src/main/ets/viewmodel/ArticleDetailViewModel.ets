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

import { BaseVM, BreakpointTypeEnum, GlobalInfoModel, LoadingStatus, PageContext } from '@ohos/common';
import { ComponentDetailParams, SampleDetailParams, TabBarType } from '@ohos/commonbusiness';
import type { DiscoverContent } from '../model/DiscoverData';
import { ExplorationDetailState } from './ExplorationDetailState';

export class ArticleDetailViewModel extends BaseVM<ExplorationDetailState> {
  public constructor() {
    super(new ExplorationDetailState());
    this.state.topNavigationData.isBlur = true;
  }

  sendEvent<T>(eventParam: ExplorationDetailEventParam<T>): Promise<void> | void {
    if (eventParam.type === ExplorationDetailEventType.GET_ARTICLE_DETAIL) {
      return this.getArticleDetail(eventParam.param as DetailParam);
    } else if (eventParam.type === ExplorationDetailEventType.POP) {
      const param = eventParam.param as PopParam;
      return this.pop(param.animation, param.tabBarView);
    } else if (eventParam.type === ExplorationDetailEventType.JUMP_NATIVE_PAGE) {
      return this.jumpNativePage(eventParam.param as NativePageParam);
    }
    throw new Error('Method not implemented.');
  }

  private getArticleDetail(detailParam: DetailParam): Promise<void> {
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    this.state.content = detailParam.content;
    this.state.content.detailsUrl = `resource://resfile/${detailParam.content.detailsUrl}`;
    this.state.topNavigationData.onBackClick = detailParam.onBackClick;
    return Promise.resolve();
  }

  private pop(animated: boolean = true, tabBarView: number = TabBarType.HOME): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    let currentPathStack: PageContext = AppStorage.get('pageContext') as PageContext;
    if (globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      if (tabBarView === TabBarType.HOME) {
        currentPathStack = AppStorage.get('componentListPageContext')!;
      } else if (tabBarView === TabBarType.SAMPLE) {
        currentPathStack = AppStorage.get('samplePageContext')!;
      } else {
        currentPathStack = AppStorage.get('explorationPageContext')!;
      }
    }
    currentPathStack.popPage(animated);
  }


  private jumpNativePage(param: NativePageParam): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    let pageContext: PageContext = AppStorage.get('pageContext') as PageContext;
    if (globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      if (param.tabBarView === TabBarType.HOME) {
        pageContext = AppStorage.get('componentListPageContext') as PageContext;
      } else if (param.tabBarView === TabBarType.SAMPLE) {
        pageContext = AppStorage.get('samplePageContext') as PageContext;
      } else {
        pageContext = AppStorage.get('explorationPageContext') as PageContext;
      }
    }
    pageContext.openPage({
      routerName: param.type === 'component' ? 'ComponentDetailView' : 'SampleDetailView',
      param: param.type === 'component' ?
        {
          componentName: param.componentName,
          componentId: param.id,
        } as ComponentDetailParams :
        {
          currentIndex: param.currentIndex,
          sampleCardId: param.id,
        } as SampleDetailParams,
    }, true);
  }
}

export enum ExplorationDetailEventType {
  GET_ARTICLE_DETAIL = 'getArticleDetail',
  POP = 'pop',
  HANDLE_TITLE_EFFECT = 'handleTitleEffect',
  JUMP_NATIVE_PAGE = 'jumpNativePage',
}

export interface ExplorationDetailEventParam<T> {
  type: ExplorationDetailEventType;
  param: T;
}

export interface DetailParam {
  content: DiscoverContent;
  onBackClick: Function;
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
  componentName?: string;
}