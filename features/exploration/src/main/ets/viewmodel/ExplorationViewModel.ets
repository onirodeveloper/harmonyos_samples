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
import {
  LoadingStatus,
  Logger,
  PageContext,
  RequestErrorCode,
  StorageKey,
  WindowUtil,
  PageEnum,
  GlobalInfoModel,
  InteractionTypeEnum,
} from '@ohos/common';
import type { BannerData } from '@ohos/commonbusiness';
import {
  ArticleDetailParams,
  BaseHomeEventParam,
  BaseHomeEventType,
  BaseHomeViewModel,
  TAB_CONTENT_STATUSES,
  TabBarType,
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
      return this.loadDiscoveryPage();
    } else if (eventType === ExplorationEventType.JUMP_DETAIL_VIEW) {
      return this.jumpDetailView(eventParam.param as DiscoverContent);
    } else {
      return super.sendEvent(eventParam as BaseHomeEventParam<T>);
    }
  }

  protected loadDiscoveryPage(): void {
    const isDark: boolean = AppStorage.get(StorageKey.COLOR_MODE) === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    WindowUtil.updateStatusBarColor(isDark);
    this.model.getDiscoveryPage()
      .then((result: DiscoverData) => {
        result.bannerInfos?.forEach((item: BannerData) => {
          item.tabViewType = TabBarType.PRACTICE;
        });
        this.state.bannerState.bannerResource.setDataArray([...(result.bannerInfos || [])]);
        this.state.discoveryData = result.discoveryData;
        const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
        if (globalInfoModel?.widthBreakpoint !== WidthBreakpoint.WIDTH_LG &&
          globalInfoModel?.widthBreakpoint !== WidthBreakpoint.WIDTH_XL &&
          !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
          WindowUtil.updateStatusBarColor(true);
          TAB_CONTENT_STATUSES[TabBarType.PRACTICE] = true;
          this.setTitleBarStyle();
        }
        this.state.loadingModel.loadingStatus = LoadingStatus.SUCCESS;
        Logger.info(TAG, `Request DiscoveryPage Success`);
      })
      .catch((error: BusinessError) => {
        WindowUtil.updateStatusBarColor(isDark);
        TAB_CONTENT_STATUSES[TabBarType.PRACTICE] = isDark;
        this.setTitleBarStyle(true);
        if (error.code === RequestErrorCode.NETWORK_CONNECT_FAILED) {
          this.state.loadingModel.loadingStatus = LoadingStatus.NO_NETWORK;
        } else {
          this.state.loadingModel.loadingStatus = LoadingStatus.FAILED;
        }
      });
  }

  protected jumpDetailView(content: DiscoverContent): void {
    const pathStack = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
      AppStorage.get<PageContext>(StorageKey.EXPLORATION_PAGE_CONTEXT) :
      AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    const articleParam: ArticleDetailParams = {
      id: content.id,
      isArticle: true,
      title: content.title,
      desc: content.desc,
      detailsUrl: content.detailsUrl,
      interactionType: InteractionTypeEnum.ARTICLE,
    };
    pathStack?.openPage({
      routerName: PageEnum.ARTICLE_DETAIL_VIEW,
      param: articleParam,
    }, true);
  }
}

export enum ExplorationEventType {
  JUMP_DETAIL_VIEW = 'jumpDetailView',
  LOAD_DISCOVERY_PAGE = 'loadDiscoveryPage',
}

export interface ExplorationEventParam<T> {
  type: ExplorationEventType | BaseHomeEventType;
  param: T;
}