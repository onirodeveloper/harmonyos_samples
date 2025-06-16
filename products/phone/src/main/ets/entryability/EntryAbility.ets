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
import { BundleManagerUtil, Logger, PageContext, WindowUtil, DynamicInstallManager, WebUtil } from '@ohos/common';
import GlobalUIAbilityContext from '../util/ContextConfig';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    this.checkAndHandleParams(want);
    AppStorage.setOrCreate('systemColorMode', this.context.config.colorMode);
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, `onNewWant`);
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
    WindowUtil.requestFullScreen(windowStage, this.context);
    WindowUtil.registerBreakPoint(windowStage);
    BundleManagerUtil.getBundleInfo();
    AppStorage.setOrCreate('pageContext', new PageContext());
    AppStorage.setOrCreate('samplePageContext', new PageContext());
    AppStorage.setOrCreate('componentListPageContext', new PageContext());
    AppStorage.setOrCreate('explorationPageContext', new PageContext());
    windowStage.loadContent('page/SplashPage', (err: BusinessError) => {
      WebUtil.initialize(windowStage);
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. Cause: ${err.code} ${err.message}`);
        return;
      }
      // Hide PC/2in1 title bar after loadContent success.
      WindowUtil.hideTitleBar(windowStage);
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    const newColorMode: ConfigurationConstant.ColorMode =
      newConfig.colorMode || ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const currentColorMode = AppStorage.get<ConfigurationConstant.ColorMode>('systemColorMode');
    // When the system dark/light color mode is different form the app color mode,modify the app's color mode.
    if (newColorMode !== currentColorMode) {
      AppStorage.setOrCreate('systemColorMode', newColorMode);
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