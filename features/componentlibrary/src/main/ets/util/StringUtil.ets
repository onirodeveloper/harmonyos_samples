/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

export class StringUtil {
  public static getTemplateString(num: number): string {
    let str = '';
    for (let i = 0; i < num; i++) {
      str += '1fr ';
    }
    return str.trim();
  }

  // Translate the input numeric string into an array of individual character numbers.
  public static stringToArray(inputStr: string): number[] {
    if (inputStr.trim() === '') {
      return [];
    }
    return inputStr.split(',').map(Number);
  }
}