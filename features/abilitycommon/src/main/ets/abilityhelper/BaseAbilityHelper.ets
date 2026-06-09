/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import { AbilityConstant, appRecovery, common, Configuration, ConfigurationConstant, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { insightIntent } from '@kit.IntentsKit';
import {
  BundleManagerUtil,
  DynamicInstallManager,
  FormCardEnum,
  Logger,
  PageContext,
  PullUpManager,
  StorageKey,
  TrackManager,
  WebUtil,
  WindowUtil,
} from '@ohos/common';
import IntentEntryCustom from '../intentframework/IntentEntryCustom';
import IntentCourseModel from '../model/IntentCourseModel';
import GlobalUIAbilityContext from '../util/ContextConfig';
import { UpdateFormData } from '../widget/viewmodel/UpdateFormData';

const TAG = '[BaseAbilityHelper]';

export class BaseAbilityHelper {
  private context?: common.UIAbilityContext;

  constructor() {
  }

  public doOnCreate(context: common.UIAbilityContext, want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context = context;
    appRecovery.enableAppRecovery(appRecovery.RestartFlag.RESTART_WHEN_JS_CRASH);
    Logger.info(TAG, `Ability onCreate launchReason: ${launchParam.launchReason}`);
    this.handleWantParam(want);
    AppStorage.setOrCreate(StorageKey.COLOR_MODE, this.context?.config.colorMode);
    try {
      this.context?.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `onCreate setColorMode failed, ${err.code}, ${err.message}`);
    }

    IntentEntryCustom.getInstance();
    this.initShareIntent();
  }

  public doOnNewWant(context: common.UIAbilityContext, want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context = context;
    Logger.info(TAG, `onNewWant launchReason: ${launchParam.launchReason}`);
    this.handleWantParam(want);
  }

  private handleWantParam(want: Want) {
    AppStorage.setOrCreate(StorageKey.CONTEXT_ENTRY, this.context);
    if (want.parameters?.['ohos.aafwk.param.callerBundleName']) {
      AppStorage.setOrCreate('caller', want.parameters?.['ohos.aafwk.param.callerBundleName']);
    }
    if (PullUpManager.getFormCardType(want) === FormCardEnum.ARTICLE_SERVICE_CARD) {
      UpdateFormData.update(want.parameters?.['formId'] as string);
    }
    if (want?.parameters &&
      want?.action === '' &&
      Reflect.has(want.parameters, 'ohos.insightIntent.executeParam.param')) {

      const customIntent: object = IntentEntryCustom.getInstance();
      Logger.info(TAG, `customIntent: ${JSON.stringify(customIntent)}`);
    }
    PullUpManager.pullUpApp(want);
  }

  public doOnDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    DynamicInstallManager.unsubscribeDownloadProgress();
  }

  public doOnWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    // Use for penkit component
    if (this.context) {
      GlobalUIAbilityContext.setContext(this.context);
    }
    AppStorage.setOrCreate(StorageKey.HOME_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.SAMPLE_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.COMPONENT_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.EXPLORATION_PAGE_CONTEXT, new PageContext());
    AppStorage.setOrCreate(StorageKey.MINE_PAGE_CONTEXT, new PageContext());
    BundleManagerUtil.getBundleInfo();
    DynamicInstallManager.subscribeDownloadProgress();
    windowStage.loadContent('page/SplashPage', (err: BusinessError) => {
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. Cause: ${err.code} ${err.message}`);
        return;
      }
      WebUtil.initialize(windowStage);
      WindowUtil.initialize(windowStage);
      TrackManager.getInstance().initTrackManager();
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  public doOnConfigurationUpdate(newConfig: Configuration): void {
    const newColorMode: ConfigurationConstant.ColorMode =
      newConfig.colorMode || ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const currentColorMode = AppStorage.get<ConfigurationConstant.ColorMode>(StorageKey.COLOR_MODE);
    // When the system dark/light color mode is different form the app color mode,modify the app's color mode.
    if (newColorMode !== currentColorMode) {
      AppStorage.setOrCreate(StorageKey.COLOR_MODE, newColorMode);
    }
  }

  public doOnWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    TrackManager.getInstance().offTrackManager();
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  public doOnForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  public doOnBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  private initShareIntent() {
    const intentsToBeShared = IntentCourseModel.localSearchAll();
    Logger.debug(TAG, `Context: ${JSON.stringify(this.context)}`);
    Logger.info(TAG, `Intents[0]: ${JSON.stringify(intentsToBeShared[0])}`);
    insightIntent.shareIntent(this.context, intentsToBeShared).then(() => {
      Logger.info(TAG, `IntentShare: sharing Intent succeed. Number of intents: ${intentsToBeShared.length}`);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `IntentShare: Error ${err?.code}: Failed to share Intent, error message: ${err?.message}`);
    });
  }
}
