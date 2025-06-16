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
import type { GlobalInfoModel, ResponseData, } from '@ohos/common';
import {
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
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
  ComponentDetailParams,
  TabBarType,
  TAB_CONTENT_STATUSES,
} from '@ohos/commonbusiness';
import type { ComponentContent, ComponentData } from '../model/ComponentData';
import { ComponentListModel } from '../model/ComponentListModel';
import { ComponentListState } from './ComponentListState';

const TAG = '[ComponentListViewModel]';

export class ComponentListViewModel extends BaseHomeViewModel<ComponentListState> {
  private static instance: ComponentListViewModel;
  private globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  private componentListModel: ComponentListModel = ComponentListModel.getInstance();
  private bannerColumnSection: SectionOptions = {
    itemsCount: 1,
    crossCount: 1,
  };
  private componentColumnSection: SectionOptions = {
    itemsCount: 0,
    crossCount: new BreakpointType({
      sm: 1,
      md: 2,
      lg: 3,
    }).getValue(this.globalInfoModel.currentBreakpoint),
    margin: $r('sys.float.padding_level8'),
  };
  private footerSection: SectionOptions = {
    itemsCount: 1,
    crossCount: 1,
  };

  private constructor() {
    super(new ComponentListState());
    this.state.topNavigationData.title = $r('app.string.component_name');
  }

  public static getInstance(): ComponentListViewModel {
    if (!ComponentListViewModel.instance) {
      ComponentListViewModel.instance = new ComponentListViewModel();
    }
    return ComponentListViewModel.instance;
  }

  public sendEvent<T>(eventParam: ComponentListEventParam<T>): void | boolean {
    const eventType: ComponentListEventType | BaseHomeEventType = eventParam.type;
    if (eventType === ComponentListEventType.LOAD_COMPONENT_PAGE) {
      return this.loadComponentPage();
    } else if (eventType === ComponentListEventType.JUMP_DETAIL_DETAIL) {
      return this.jumpComponentDetail(eventParam.param as ComponentContent);
    } else if (eventType === ComponentListEventType.UPDATE_FLOW_SECTION) {
      return this.updateFlowSection();
    } else {
      return super.sendEvent(eventParam as BaseHomeEventParam<T>);
    }
  }

  protected loadComponentPage(): void {
    const isDark: boolean = AppStorage.get('systemColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    this.state.loadingModel.loadingStatus = LoadingStatus.LOADING;
    this.state.topNavigationData.titleColor = isDark ? StatusBarColorType.WHITE : StatusBarColorType.BLACK;
    this.state.topNavigationData.isBlur = false;
    WindowUtil.updateStatusBarColor(getContext(), isDark);
    this.componentListModel.getComponentPage(this.state.currentPage, this.pageSize)
      .then((result: ResponseData<ComponentData>) => {
        if (result.data.bannerInfos) {
          result.data.bannerInfos.forEach((item: BannerData) => {
            item.tabViewType = TabBarType.HOME;
          });
          this.state.bannerState.bannerResource.setDataArray([...result.data.bannerInfos]);
        }
        this.state.cardSource.setDataArray(result.data.cardData);
        this.updateFlowSection();
        this.state.loadingModel.hasNextPage =
          result.data.cardData.length === this.pageSize && (result.totalSize > this.state.currentPage * this.pageSize);
        const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
        if (globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.LG &&
          globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL) {
          this.state.topNavigationData.titleColor = StatusBarColorType.WHITE;
          WindowUtil.updateStatusBarColor(getContext(), true);
          TAB_CONTENT_STATUSES[TabBarType.HOME] = true;
        }
        this.state.loadingModel.loadingStatus = LoadingStatus.SUCCESS;
      })
      .catch((error: BusinessError) => {
        WindowUtil.updateStatusBarColor(getContext(), isDark);
        TAB_CONTENT_STATUSES[TabBarType.HOME] = isDark;
        if (error.code === RequestErrorCode.ERROR_NETWORK_CONNECT_FAILED) {
          this.state.loadingModel.loadingStatus = LoadingStatus.NO_NETWORK;
        } else {
          this.state.loadingModel.loadingStatus = LoadingStatus.FAILED;
        }
      });
  }

  protected updateFlowSection(): void {
    this.componentColumnSection.itemsCount = this.state.cardSource.totalCount();
    const crossCount: number = new BreakpointType({
      sm: 1,
      md: 2,
      lg: 3,
    }).getValue(this.globalInfoModel.currentBreakpoint);
    const leftMargin: Length =
      new BreakpointType<Length>({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: CommonConstants.SPACE_32 + CommonConstants.TAB_BAR_WIDTH,
        xl: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.currentBreakpoint);
    const rightMargin: Resource = new BreakpointType({
      sm: $r('sys.float.padding_level8'),
      md: $r('sys.float.padding_level12'),
      lg: $r('sys.float.padding_level16'),
    }).getValue(this.globalInfoModel.currentBreakpoint);
    const columnMargin: Resource = new BreakpointType({
      sm: $r('sys.float.padding_level8'),
      md: $r('sys.float.padding_level10'),
      lg: $r('sys.float.padding_level12'),
    }).getValue(this.globalInfoModel.currentBreakpoint);
    const margin: Margin = {
      left: leftMargin,
      right: rightMargin,
      top: columnMargin,
      bottom: $r('sys.float.padding_level6'),
    };

    this.componentColumnSection.crossCount = crossCount;
    this.componentColumnSection.margin = margin;
    this.footerSection.margin = { left: leftMargin, right: rightMargin };
    this.state.sections.splice(0, this.state.sections.length(),
      [this.bannerColumnSection, this.componentColumnSection, this.footerSection]);
    Logger.debug(TAG, `updateFlowSection ${JSON.stringify(this.state.cardSource)}`);
  }

  protected jumpComponentDetail(componentContent: ComponentContent) {
    const pageContext: PageContext =
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('componentListPageContext')! :
        AppStorage.get('pageContext')!;
    const params: ComponentDetailParams = {
      componentName: componentContent.title,
      componentId: componentContent.id,
    };
    pageContext.openPage({
      routerName: 'ComponentDetailView',
      param: params,
    }, true);
  }
}

export enum ComponentListEventType {
  JUMP_DETAIL_DETAIL = 'jumpDetailView',
  LOAD_COMPONENT_PAGE = 'loadComponentPage',
  UPDATE_FLOW_SECTION = 'updateFlowSection',
}

export interface ComponentListEventParam<T> {
  type: ComponentListEventType | BaseHomeEventType;
  param: T;
}