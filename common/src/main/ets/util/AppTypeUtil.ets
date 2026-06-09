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

export class AppTypeUtil {
  private static appTypeKey: string = 'hmos_world_AppTypeKey';

  /**
   * Set app type.
   * @param type appType
   */
  public static setAppType(type: AppType): void {
    if (!type) {
      return;
    }
    AppStorage.setOrCreate(AppTypeUtil.appTypeKey, type);
  }

  /**
   * Check is phone app type.
   * @returns
   */
  static isPhoneApp(): boolean {
    const type = AppTypeUtil.getAppType();
    return type === AppType.PHONE;
  }

  /**
   * Check is pc app type.
   * @returns
   */
  static isPcApp(): boolean {
    const type = AppTypeUtil.getAppType();
    return type === AppType.PC;
  }

  /**
   * Check is wearable app type.
   * @returns
   */
  static isWearableApp(): boolean {
    const type = AppTypeUtil.getAppType();
    return type === AppType.WEARABLE;
  }

  /**
   * Check is tv app type.
   * @returns
   */
  static isTvApp(): boolean {
    const type = AppTypeUtil.getAppType();
    return type === AppType.TV;
  }

  /**
   * Get app type.
   * @returns
   */
  private static getAppType(): string | undefined {
    return AppStorage.get(AppTypeUtil.appTypeKey);
  }
}

export enum AppType {
  PHONE = 'phone',
  PC = 'pc',
  WEARABLE = 'wearable',
  TV = 'tv',
  CAR = 'car',
}