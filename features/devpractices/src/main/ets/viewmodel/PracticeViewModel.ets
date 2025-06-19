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

import { ConfigurationConstant } from '@kit.AbilityKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import type { GlobalInfoModel, ResponseData } from '@ohos/common';
import {
  BreakpointTypeEnum,
  LoadingModel,
  LoadingStatus,
  Logger,
  PageContext,
  RequestErrorCode,
  StatusBarColorType,
  WindowUtil,
} from '@ohos/common';
import type { BannerData } from '@ohos/commonbusiness';
import {
  BaseHomeEventParam,
  BaseHomeEventType,
  BaseHomeViewModel,
  SampleDetailParams,
  TAB_CONTENT_STATUSES,
  TabBarType,
} from '@ohos/commonbusiness';
import type { SampleCardData, SampleCategory, SampleData } from '../model/SampleData';
import { SampleModel } from '../model/SampleModel';
import { PracticeState } from './PracticeState';

const TAG = '[PracticeViewModel]';

export class PracticeViewModel extends BaseHomeViewModel<PracticeState> {
  private static instance: PracticeViewModel;
  private sampleModel: SampleModel = SampleModel.getInstance();

  private constructor() {
    super(new PracticeState());
    this.state.topNavigationData.title = $r('app.string.sample_name');
  }

  static getInstance(): PracticeViewModel {
    if (!PracticeViewModel.instance) {
      PracticeViewModel.instance = new PracticeViewModel();
    }
    return PracticeViewModel.instance;
  }

  sendEvent<T>(eventParam: PracticeEventParam<T>): void | boolean {
    const eventType: PracticeEventType | BaseHomeEventType = eventParam.type;
    if (eventType === PracticeEventType.LOAD_SAMPLE_PAGE) {
      return this.loadSamplePage(eventParam.param as LoadSamplePageParam);
    } else if (eventType === PracticeEventType.LOAD_SAMPLE_LIST) {
      return this.loadSampleList(eventParam.param as SampleCategory);
    } else if (eventType === PracticeEventType.JUMP_DETAIL_DETAIL) {
      return this.jumpDetailView(eventParam.param as SampleDetailParams);
    } else {
      return super.sendEvent(eventParam as BaseHomeEventParam<T>);
    }
  }

  protected loadSamplePage(param: LoadSamplePageParam): void {
    const isDark: boolean = AppStorage.get('systemColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    this.state.topNavigationData.titleColor = isDark ? StatusBarColorType.WHITE : StatusBarColorType.BLACK;
    this.state.topNavigationData.isBlur = false;
    WindowUtil.updateStatusBarColor(getContext(), isDark);
    this.sampleModel.getSamplePage(1, this.pageSize)
      .then((result: ResponseData<SampleData>) => {
        if (result.data.bannerInfos) {
          result.data.bannerInfos.forEach((item: BannerData) => {
            item.tabViewType = TabBarType.SAMPLE;
          });
          this.state.bannerState.bannerResource.setDataArray([...result.data.bannerInfos]);
        }
        const categoryList: SampleCategory[] = [];
        result.data.sampleCategories.forEach((sampleCategory: SampleCategory) => {
          sampleCategory.currentPage = 1;
          sampleCategory.loadingModel = new LoadingModel();
          sampleCategory.loadingModel.loadingStatus =
            sampleCategory.sampleCards?.length === 0 ? LoadingStatus.OFF : LoadingStatus.SUCCESS;
          sampleCategory.loadingModel.hasNextPage = false;
          categoryList.push(sampleCategory);
        });
        this.state.sampleCategories = categoryList;
        const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
        if (globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.LG &&
          globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL) {
          this.state.topNavigationData.titleColor = StatusBarColorType.WHITE;
          WindowUtil.updateStatusBarColor(getContext(), true);
          TAB_CONTENT_STATUSES[TabBarType.SAMPLE] = true;
        }
        this.state.loadingModel.loadingStatus = LoadingStatus.SUCCESS;
        param.callback();
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `load PracticePage Failed, ${error.code} ${error.message}`);
        WindowUtil.updateStatusBarColor(getContext(), isDark);
        TAB_CONTENT_STATUSES[TabBarType.SAMPLE] = isDark;
        if (error.code === RequestErrorCode.ERROR_NETWORK_CONNECT_FAILED) {
          this.state.loadingModel.loadingStatus = LoadingStatus.NO_NETWORK;
        } else {
          this.state.loadingModel.loadingStatus = LoadingStatus.FAILED;
        }
      });
  }

  protected loadSampleList(currentCategory: SampleCategory): void {
    currentCategory.loadingModel = new LoadingModel(LoadingStatus.LOADING);
    this.changeSampleCategories(currentCategory);
    this.sampleModel.getSampleList(currentCategory.categoryType, currentCategory.currentPage, this.pageSize)
      .then((result: ResponseData<SampleCardData[]>) => {
        currentCategory.loadingModel.loadingStatus = LoadingStatus.SUCCESS;
        currentCategory.loadingModel.hasNextPage =
          result.data.length === this.pageSize && (result.totalSize > currentCategory.currentPage * this.pageSize);
        currentCategory.sampleCards = (currentCategory.sampleCards || []).concat(result.data);
        this.changeSampleCategories(currentCategory);
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `getSampleList failed,cause ${error.code} ${error.message}`);
        if (error.code === RequestErrorCode.ERROR_NETWORK_CONNECT_FAILED) {
          currentCategory.loadingModel = new LoadingModel(LoadingStatus.NO_NETWORK);
        } else {
          currentCategory.loadingModel = new LoadingModel(LoadingStatus.FAILED);
        }
        this.changeSampleCategories(currentCategory);
      });
  }

  protected jumpDetailView(param: SampleDetailParams): void {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
    const pageContext: PageContext =
      globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('samplePageContext')! :
        AppStorage.get('pageContext') as PageContext;
    pageContext.openPage({
      routerName: 'SampleDetailView',
      param: param,
    }, true);
  }

  private changeSampleCategories(currentCategory: SampleCategory): void {
    const categoryList: SampleCategory[] = [];
    this.state.sampleCategories.forEach((sampleCategory: SampleCategory) => {
      if (sampleCategory.categoryType === currentCategory.categoryType) {
        categoryList.push(currentCategory);
      } else {
        categoryList.push(sampleCategory);
      }
    });
    this.state.sampleCategories = categoryList;
  }
}

export enum PracticeEventType {
  JUMP_DETAIL_DETAIL = 'jumpDetailView',
  LOAD_SAMPLE_LIST = 'loadSampleList',
  LOAD_SAMPLE_PAGE = 'loadSamplePage',
}

export interface PracticeEventParam<T> {
  type: PracticeEventType | BaseHomeEventType;
  param: T;
}

export interface LoadSamplePageParam {
  callback: Function;
}