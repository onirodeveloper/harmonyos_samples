/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { UIContext } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { BaseVM, Logger, ProcessUtil, StorageKey, Toast } from '@ohos/common';
import { VisionSampleModel } from '../model/VisionSampleModel';
import { SingleSampleData } from '@ohos/devpractices';
import { MainState } from './MainState';

const TAG: string = '[MainViewModel]';

export enum MainEventType {
  INIT = 'init',
  EXPERIENCE_CLICK = 'experienceClick',
  SOURCE_CLICK = 'sourceClick'
}

export interface MainEvent {
  type: MainEventType;
  data?: number;
}

export class MainViewModel extends BaseVM<MainState> {
  private static instance: MainViewModel;
  private versionSampleModel: VisionSampleModel = VisionSampleModel.getInstance();

  private constructor() {
    super(new MainState());
  }

  public static getInstance(): MainViewModel {
    if (!MainViewModel.instance) {
      MainViewModel.instance = new MainViewModel();
    }
    return MainViewModel.instance;
  }

  public sendEvent(event: MainEvent): void {
    switch (event.type) {
      case MainEventType.INIT:
        this.init();
        break;
      case MainEventType.EXPERIENCE_CLICK:
        this.onExperienceClick(event.data);
        break;
      case MainEventType.SOURCE_CLICK:
        this.onSourceClick();
        break;
    }
  }

  private init(): void {
    Logger.info(TAG, 'MainViewModel init');
    this.versionSampleModel.getVisionSampleList()
      .then((result: SingleSampleData[]) => {
        this.state.bannerList = result;
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `load VersionSampleList Failed, ${error.code} ${error.message}`);
      })
  }

  private onExperienceClick(index?: number): void {
    Logger.info(TAG, 'Experience button clicked');
    if (index === undefined || index < 0 || index >= this.state.bannerList.length) {
      Logger.error(TAG, `Experience click failed, invalid index: ${index}`);
      return;
    }
    const sample: SingleSampleData = this.state.bannerList[index];
    const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT)!;
    const context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
    if (!context) {
      Logger.error(TAG, `LoadSample failed, cause context is undefined`);
      return;
    }
    if (!sample.abilityName) {
      Logger.error(TAG, `LoadSample failed, abilityName is empty`);
      return;
    }
    if (sample.apiVersion > deviceInfo.sdkApiVersion) {
      Toast.showToast($r('app.string.api_prompt'));
    } else {
      ProcessUtil.startAbility(context, {
        bundleName: context.abilityInfo.bundleName,
        abilityName: sample.abilityName,
      });
    }
  }

  private onSourceClick(): void {
    Logger.info(TAG, 'Source button clicked');
    const index: number = this.state.currentBannerIndex;
    if (index < 0 || index >= this.state.bannerList.length) {
      Logger.error(TAG, `Source click failed, invalid index: ${index}`);
      return;
    }
    const sample: SingleSampleData = this.state.bannerList[index];
    if (!sample.originalUrl) {
      Logger.error(TAG, `Source click failed, originalUrl is empty`);
      return;
    }
  }
}
