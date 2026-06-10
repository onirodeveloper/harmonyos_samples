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
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { TrackManager, WindowUtil, Logger, StorageKey, PageContext, BundleManagerUtil } from '@ohos/common';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `onCreate setColorMode failed, ${err.code}, ${err.message}`);
    }
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        Logger.error(TAG, `Failed to load content. Cause: ${JSON.stringify(err)}`);
        return;
      }
      WindowUtil.initialize(windowStage);
      TrackManager.getInstance().initTrackManager();
      Logger.info(TAG, 'Succeeded in loading content.');
      AppStorage.setOrCreate(StorageKey.HOME_PAGE_CONTEXT, new PageContext());
      AppStorage.setOrCreate(StorageKey.MINE_PAGE_CONTEXT, new PageContext());
      BundleManagerUtil.getBundleInfo();
    });

    windowStage.getMainWindow((err, mainWindow) => {
      if (err.code) {
        Logger.error(TAG, `Failed to obtain main window. Cause: ${JSON.stringify(err)}`);
        return;
      }

      try {
        mainWindow.setWindowLayoutFullScreen(true).then(() => {
          Logger.info(TAG, 'Succeeded in setting window layout full screen.');
        }).catch((err: BusinessError) => {
          Logger.error(TAG, `Failed to set window layout full screen. Cause: ${JSON.stringify(err)}`);
        });
      } catch (exception) {
        Logger.error(TAG, `Failed to set window layout full screen. Cause: ${JSON.stringify(exception)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
    TrackManager.getInstance().offTrackManager();
  }

  onForeground(): void {
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, 'Ability onBackground');
  }
}