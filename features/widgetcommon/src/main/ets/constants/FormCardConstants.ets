/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the License);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export class FormCardConstants {
  /**
   * Adapt the 5.0.
   */
  public static readonly FULL_PERCENT: Length = '100%';
  public static readonly CARD_CONTENT_WIDTH = '80%';
  public static readonly ACTION_TYPE: string = 'router';
  public static readonly ABILITY_NAME: string = 'PcAbility';
  public static readonly OPACITY_LG: number = 0.8;
}

export const fluffyList: string[] = [
  'Fluffy_1', 'Fluffy_2', 'Fluffy_3', 'Fluffy_4', 'Fluffy_5', 'Fluffy_6', 'Fluffy_7', 'Fluffy_8', 'Fluffy_9',
  'Fluffy_10'
]

export const codeList: string[] = [
  'Code_1', 'Code_2', 'Code_3', 'Code_3', 'Code_4'
]

export const delayParams: number[] = [
  200, 700, 1100, 1400, 1800
]

// 3D Live Widget
// How large should live-card be:
export const LIVE_CARD_RATIO: number = 1.20;

/** Foreground and background 's moving sensitivity,
 * Positive value: elements move leftward when phone rotated towards left
 * (screen facing user's left ear)
 */
export const FLUFFY_SENSOR_RATE: number = -0.75;

export const MONITOR_SENSOR_RATE: number = -0.25;

// Moving rate of zTransfer
export const BOTH_Z_SENSOR_RATE: number = -1.0;

// Widget background color when activated
export const WIDGET_BG_UPPER: string = '60, 100, 220'; // RGB

export const WIDGET_BG_LOWER: string = '30, 150, 230'; // RGB

interface OffsetData {
  x: number,
  y: number
}

export class WidgetImageOffsetData {
  public static readonly FLUFFY_POSITION: OffsetData = {
    x: -10,
    y: 16,
  }
  public static readonly MONITOR_POSITION: OffsetData = {
    x: 87,
    y: 2
  }
}


export class PicTranslateData {
  public static readonly TRANSLATE_X_MIN: number = -10;
  public static readonly TRANSLATE_X_MAX: number = 10;
  public static readonly TRANSLATE_Y_MIN: number = -10;
  public static readonly TRANSLATE_Y_MAX: number = 10;
  public static readonly TRANSLATE_Z_MIN: number = -10;
  public static readonly TRANSLATE_Z_MAX: number = 10;
}

export const GYROSCOPE_REFRESHING_INTERVAL = 50000000;