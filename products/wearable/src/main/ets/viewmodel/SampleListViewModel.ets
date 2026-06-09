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

import { common } from '@kit.AbilityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { BaseVM, Logger, PageContext, ProcessUtil, StorageKey, PageEnum, Toast } from '@ohos/common';
import { WearableSampleData } from '../model/WearableSampleData';
import { WearableSampleModel } from '../model/WearableSampleModel';
import { SampleListState } from './SampleListState';

const TAG = '[SampleListViewModel]';

export class SampleListViewModel extends BaseVM<SampleListState> {
  private static instance: SampleListViewModel;
  private wearableSampleModel: WearableSampleModel = WearableSampleModel.getInstance();

  private constructor() {
    super(new SampleListState());
  }

  public static getInstance(): SampleListViewModel {
    if (!SampleListViewModel.instance) {
      SampleListViewModel.instance = new SampleListViewModel();
    }
    return SampleListViewModel.instance;
  }

  public sendEvent<T>(eventParam: SampleListEventParam<T>): void {
    const eventType: SampleListEventType = eventParam.type;
    if (eventType === SampleListEventType.LOAD_SAMPLE_LIST) {
      this.loadWearableSampleList();
    } else if (eventType === SampleListEventType.LOAD_SAMPLE) {
      this.loadSample(eventParam.param as LoadSampleParam);
    } else if (eventType === SampleListEventType.JUMP_TO_SOURCE_CODE_LINK_PAGE) {
      this.jumpToSourceCodeLinkPage(eventParam.param as SourceCodeLinkPageParam);
    }
  }

  private loadWearableSampleList() {
    this.wearableSampleModel.getWearableSampleList()
      .then((result: WearableSampleData[]) => {
        this.state.wearableSampleList = result;
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `load WearableSampleList Failed, ${error.code} ${error.message}`);
      })
  }

  private loadSample(param: LoadSampleParam): void {
    const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT)!;
    const context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
    if (!context) {
      Logger.error(TAG, `LoadSample failed, cause context is undefined`);
      return;
    }
    if (param.apiVersion > deviceInfo.sdkApiVersion) {
      Toast.showToast($r('app.string.api_prompt'));
    } else {
      ProcessUtil.startAbility(context, {
        bundleName: context.abilityInfo.bundleName,
        abilityName: param.abilityName,
      });
    }
  }

  private jumpToSourceCodeLinkPage(param: SourceCodeLinkPageParam): void {
    const pageContext: PageContext =
      AppStorage.get<PageContext>('pageContext') ?? new PageContext();
    pageContext.openPage({
      routerName: PageEnum.WEARABLE_SOURCE_CODE_VIEW,
      param: param
    });
  }
}

export enum SampleListEventType {
  LOAD_SAMPLE_LIST = 'loadSamplePage',
  LOAD_SAMPLE = 'loadSample',
  JUMP_TO_SOURCE_CODE_LINK_PAGE = 'jumpToSourceCodeLinkPage',
}

export interface SampleListEventParam<T> {
  type: SampleListEventType;
  param?: T;
}

export interface LoadSampleParam {
  abilityName: string;
  apiVersion: number;
}

export interface SourceCodeLinkPageParam {
  sourceCodeLink: string;
  title: string;
}