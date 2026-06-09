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

import { Want } from '@kit.AbilityKit';

export class WantUtil {
  /**
   * Get param value by key from want.
   * @param want
   * @param key
   * @param defValue
   * @returns value from parameter with key.
   */
  static getParameter<T>(want: Want, key: string, defValue?: T): T | undefined {
    if (!want || !want.parameters || !key) {
      return undefined;
    }
    const result = want.parameters[key];
    if (!result) {
      return defValue;
    }
    return result as T;
  }

  /**
   * Want security monitoring.
   * @param want
   * @returns
   */
  static emptyCheck(want?: Want): Want {
    if (!want) {
      return {};
    }
    return want;
  }
}