/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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
import type { BusinessError } from '@kit.BasicServicesKit';
import type { GlobalInfoModel } from '@ohos/common';
import {
  BreakpointTypeEnum,
  LoadingStatus,
  Logger,
  PageContext,
  RequestErrorCode,
  StatusBarColorType,
  WindowUtil,
} from '@ohos/common';
import type { BannerData } from '@ohos/commonbusiness';
import {
  ArticleDetailParams,
  BaseHomeEventParam,
  BaseHomeEventType,
  BaseHomeViewModel,
  TabBarType,
  TAB_CONTENT_STATUSES,
} from '@ohos/commonbusiness';
import type { DiscoverContent, DiscoverData } from '../model/DiscoverData';
import { DiscoverModel } from '../model/DiscoverModel';
import { ExplorationState } from './ExplorationState';

const TAG = '[ExplorationViewModel]';

export class ExplorationViewModel extends BaseHomeViewModel<ExplorationState> {
  private static instance: ExplorationViewModel;
  private model: DiscoverModel = DiscoverModel.getInstance();

  private constructor() {
    super(new ExplorationState());
    this.state.topNavigationData.title = $r('app.string.practice_name');
  }

  public static getInstance(): ExplorationViewModel {
    if (!ExplorationViewModel.instance) {
      ExplorationViewModel.instance = new ExplorationViewModel();
    }
    return ExplorationViewModel.instance;
  }

  sendEvent<T>(eventParam: ExplorationEventParam<T>): void | boolean {
    const eventType: ExplorationEventType | BaseHomeEventType = eventParam.type;
    if (eventType === ExplorationEventType.LOAD_DISCOVERY_PAGE) {
      return this.loadDiscoverList();
    } else if (eventType === ExplorationEventType.JUMP_DETAIL_DETAIL) {
      return this.jumpDetailView(eventParam.param as DiscoverContent);
    } else {
      return super.sendEvent(eventParam as BaseHomeEventParam<T>);
    }
  }

  protected loadDiscoverList(): void {
    const isDark: boolean = AppStorage.get('systemColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    this.state.topNavigationData.titleColor = isDark ? StatusBarColorType.WHITE : StatusBarColorType.BLACK;
    this.state.topNavigationData.isBlur = false;
    WindowUtil.updateStatusBarColor(getContext(), isDark);
    this.model.getDiscoveryPage()
      .then((result: DiscoverData) => {
        result.bannerInfos?.forEach((item: BannerData) => {
          item.tabViewType = TabBarType.PRACTICE;
        });
        this.state.bannerState.bannerResource.setDataArray([...(result.bannerInfos || [])]);
        this.state.discoveryData = result.discoveryData;
        const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
        if (globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.LG &&
          globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL) {
          this.state.topNavigationData.titleColor = StatusBarColorType.WHITE;
          WindowUtil.updateStatusBarColor(getContext(), true);
          TAB_CONTENT_STATUSES[TabBarType.PRACTICE] = true;
        }
        this.state.loadingModel.loadingStatus = LoadingStatus.SUCCESS;
        Logger.info(TAG, `Request DiscoveryPage Success`);
      })
      .catch((error: BusinessError) => {
        WindowUtil.updateStatusBarColor(getContext(), isDark);
        TAB_CONTENT_STATUSES[TabBarType.PRACTICE] = isDark;
        if (error.code === RequestErrorCode.ERROR_NETWORK_CONNECT_FAILED) {
          this.state.loadingModel.loadingStatus = LoadingStatus.NO_NETWORK;
        } else {
          this.state.loadingModel.loadingStatus = LoadingStatus.FAILED;
        }
      });
  }

  protected jumpDetailView(content: DiscoverContent): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    const pathStack: PageContext =
      globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('explorationPageContext')! :
        AppStorage.get('pageContext') as PageContext;
    const articleParam: ArticleDetailParams = {
      id: content.id,
      isArticle: true,
      title: content.title,
      detailsUrl: content.detailsUrl,
    };
    pathStack.openPage({
      routerName: 'ArticleDetailView',
      param: articleParam,
    }, true);
  }
}

export enum ExplorationEventType {
  JUMP_DETAIL_DETAIL = 'jumpDetailView',
  LOAD_DISCOVERY_PAGE = 'loadDiscoverList',
}

export interface ExplorationEventParam<T> {
  type: ExplorationEventType | BaseHomeEventType;
  param: T;
}