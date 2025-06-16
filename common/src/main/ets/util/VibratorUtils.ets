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

import { vibrator } from '@kit.SensorServiceKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG: string = '[VibratorUtils]';

export class VibratorUtils {
  public static startVibration() {
    const effect: vibrator.VibrateEffect = {
      type: 'preset',
      effectId: 'haptic.clock.timer',
      count: 1,
      intensity: 50,
    };
    const attribute: vibrator.VibrateAttribute = {
      id: 0,
      usage: 'touch',
    };
    try {
      // Trigger vibrator vibration.
      vibrator.startVibration(effect, attribute, (error: BusinessError) => {
        if (error) {
          Logger.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        Logger.info(TAG, 'Succeed in starting vibration');
      });
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      Logger.error(TAG, `An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}