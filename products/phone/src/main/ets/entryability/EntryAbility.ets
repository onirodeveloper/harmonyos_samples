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

import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BundleManagerUtil,
  Logger,
  PageContext,
  WindowUtil,
  DynamicInstallManager,
  WebUtil,
  StorageKey,
} from '@ohos/common';
import GlobalUIAbilityContext from '../util/ContextConfig';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, `Ability onCreate launchReason: ${launchParam.launchReason}`);
    this.checkAndHandleParams(want);
    AppStorage.setOrCreate(StorageKey.COLOR_MODE, this.context.config.colorMode);
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch {
      Logger.error(TAG, `onCreate setColorMode failed`);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, `onNewWant launchReason: ${launchParam.launchReason}`);
    this.checkAndHandleParams(want);
  }

  checkAndHandleParams(want: Want): void {
    Logger.info(TAG, `checkAndHandleParams`);
    try {
      if (want === null || want.parameters === null || want === undefined || want.parameters === undefined) {
        return;
      }
    } catch (err) {
      Logger.error(TAG, `checkAndHandleParams failed: ${err}`);
    }
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    DynamicInstallManager.unsubscribeDownloadProgress();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    // Use for penkit component
    GlobalUIAbilityContext.setContext(this.context);
    BundleManagerUtil.getBundleInfo();
    AppStorage.setOrCreate(StorageKey.HOME_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.SAMPLE_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.COMPONENT_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.EXPLORATION_PAGE_CONTEXT, new PageContext());
    windowStage.loadContent('page/SplashPage', (err: BusinessError) => {
      WebUtil.initialize(windowStage);
      WindowUtil.initialize(windowStage);
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. Cause: ${err.code} ${err.message}`);
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    const newColorMode: ConfigurationConstant.ColorMode =
      newConfig.colorMode || ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const currentColorMode = AppStorage.get<ConfigurationConstant.ColorMode>(StorageKey.COLOR_MODE);
    // When the system dark/light color mode is different form the app color mode,modify the app's color mode.
    if (newColorMode !== currentColorMode) {
      AppStorage.setOrCreate(StorageKey.COLOR_MODE, newColorMode);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }
}