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
import { AbilityConstant, UIAbility, Configuration, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger, StorageKey } from '@ohos/common';
import { BaseAbilityHelper } from '@ohos/abilitycommon';

const TAG: string = '[PcAbility]';

export default class PcAbility extends UIAbility {
  private baseAbilityHelper: BaseAbilityHelper = new BaseAbilityHelper();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate<boolean>(StorageKey.IS_SIDEBAR_LAYOUT, true);
    this.baseAbilityHelper.doOnCreate(this.context, want, launchParam);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, `onNewWant launchReason: ${launchParam.launchReason}`);
    this.baseAbilityHelper.doOnNewWant(this.context, want, launchParam);
  }


  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    this.baseAbilityHelper.doOnDestroy();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.baseAbilityHelper.doOnWindowStageCreate(windowStage);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    this.baseAbilityHelper.doOnConfigurationUpdate(newConfig);
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
    this.baseAbilityHelper.doOnWindowStageDestroy();
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
    this.baseAbilityHelper.doOnForeground();
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
    this.baseAbilityHelper.doOnBackground();
  }
}
