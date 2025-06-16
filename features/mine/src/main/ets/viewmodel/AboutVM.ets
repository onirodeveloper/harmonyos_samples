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
import type { BusinessError } from '@kit.BasicServicesKit';
import type { BundleInfoData } from '@ohos/common';
import { BaseVM, BaseVMEvent, ConfigMapKey, Logger, ResourceUtil, UpdateService } from '@ohos/common';
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
      const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
      this.jumpToBrowser(context);
    }
  }

  private checkVersion(): void {
    this.updateService.checkUpdate().then((existNewVersion: boolean) => {
      this.state.laterVersionExist = existNewVersion;
      this.state.currentVersion = AppStorage.get<BundleInfoData>('BundleInfoData')?.versionName as string;
    });
  }

  private updateVersion(): void {
    this.state.isLoadingUpdate = true;
    this.updateService.updateVersion().then(() => {
      this.state.isLoadingUpdate = false;
    });
  }

  private jumpToBrowser(context: common.UIAbilityContext): void {
    const want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: ResourceUtil.getRawFileStringByKey(getContext(), ConfigMapKey.MIIT_URL),
    };
    context.startAbility(want)
      .then(() => {
        Logger.info(TAG, 'Start browsableAbility successfully.');
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }
}

export class CheckVersionEvent implements BaseVMEvent {
}

export class UpdateVersionEvent implements BaseVMEvent {
}

export class ViewRegistrationInfoEvent implements BaseVMEvent {
}