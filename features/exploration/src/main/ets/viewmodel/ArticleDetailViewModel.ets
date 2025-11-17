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
  BaseVM,
  CommonConstants,
  GlobalInfoModel,
  LoadingStatus,
  PageContext,
  StorageKey,
} from '@ohos/common';
import { ComponentDetailParams, SampleDetailParams, TabBarType } from '@ohos/commonbusiness';
import type { DiscoverContent } from '../model/DiscoverData';
import { ExplorationDetailState } from './ExplorationDetailState';

export class ArticleDetailViewModel extends BaseVM<ExplorationDetailState> {
  private currentPathStack?: NavPathStack;

  public constructor() {
    super(new ExplorationDetailState());
    this.state.topNavigationData.isBlur = true;
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
    } else if (eventParam.type === ExplorationDetailEventType.CHANGE_TITLE_BAR_STYLE) {
      return this.changeTitleBarStyle(eventParam.param as number);
    }
    throw new Error('Method not implemented.');
  }

  private getArticleDetail(detailParam: DetailParam): Promise<void> {
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    this.state.content = detailParam.content;
    this.state.content.detailsUrl = `resource://resfile/${detailParam.content.detailsUrl}`;
    this.state.topNavigationData.onBackClick = detailParam.onBackClick;
    this.state.topNavigationData.isFullScreen = true;
    this.changeTitleBarStyle(0);
    return Promise.resolve();
  }

  private changeTitleBarStyle(yOffset: number): void {
    this.state.topNavigationData.title = yOffset > CommonConstants.NAVIGATION_HEIGHT ? this.state.content.title : '';
    this.state.topNavigationData.isBlur = yOffset > CommonConstants.SPACE_12;
  }

  private pop(animated: boolean = true): void {
    this.currentPathStack?.pop(animated);
  }

  private jumpNativePage(param: NativePageParam): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;
    let pageContext: PageContext = AppStorage.get(StorageKey.HOME_PAGE_CONTEXT) as PageContext;
    if (globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) {
      if (param.tabBarView === TabBarType.HOME) {
        pageContext = AppStorage.get(StorageKey.COMPONENT_PAGE_CONTEXT) as PageContext;
      } else if (param.tabBarView === TabBarType.SAMPLE) {
        pageContext = AppStorage.get(StorageKey.SAMPLE_PAGE_CONTEXT) as PageContext;
      } else {
        pageContext = AppStorage.get(StorageKey.EXPLORATION_PAGE_CONTEXT) as PageContext;
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
  ASSIGN_PATH_STACK = 'AssignPathStackEvent',
  CHANGE_TITLE_BAR_STYLE = 'changeTitleBarStyle',
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

export interface AssignPathStackParam {
  navPathStack: NavPathStack;
}