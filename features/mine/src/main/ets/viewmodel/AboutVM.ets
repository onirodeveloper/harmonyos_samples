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

import type { common, Want } from '@kit.AbilityKit';
import type { BundleInfoData } from '@ohos/common';
import {
  BaseVM,
  BaseVMEvent,
  ConfigMapKey,
  Logger,
  ProcessUtil,
  ResourceUtil,
  StorageKey,
  UpdateService
} from '@ohos/common';
import { AboutState } from './AboutState';

const TAG: string = '[AboutVM]';

export class AboutVM extends BaseVM<AboutState> {
  private static instance: AboutVM;
  private updateService = UpdateService.getInstance();

  public static getInstance(): AboutVM {
    if (!AboutVM.instance) {
      AboutVM.instance = new AboutVM();
    }
    return AboutVM.instance;
  }

  private constructor() {
    super(new AboutState());
  }

  sendEvent(event: BaseVMEvent) {
    if (event instanceof CheckVersionEvent) {
      this.checkVersion();
    } else if (event instanceof UpdateVersionEvent) {
      this.updateVersion();
    } else if (event instanceof ViewRegistrationInfoEvent) {
      this.jumpToBrowser();
    }
  }

  private checkVersion(): void {
    this.updateService.checkUpdate().then((existNewVersion: boolean) => {
      this.state.laterVersionExist = existNewVersion;
      this.state.currentVersion = AppStorage.get<BundleInfoData>(StorageKey.BUNDLE_INFO)?.versionName ?? '';
    });
  }

  private updateVersion(): void {
    this.state.isLoadingUpdate = true;
    this.updateService.updateVersion().then(() => {
      this.state.isLoadingUpdate = false;
    });
  }

  private jumpToBrowser(): void {
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    const context = uiContext?.getHostContext();
    if (!uiContext || !context) {
      Logger.error(TAG, `Failed to jumpToBrowser. Cause uicontext or context is undefined.`);
      return;
    }
    const want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.MIIT_URL) as string,
    };
    ProcessUtil.startAbility(context as common.UIAbilityContext, want);
  }
}

export class CheckVersionEvent implements BaseVMEvent {
}

export class UpdateVersionEvent implements BaseVMEvent {
}

export class ViewRegistrationInfoEvent implements BaseVMEvent {
}