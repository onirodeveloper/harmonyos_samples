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

export class CommonColorMapping {
  public readonly code: string;
  public readonly value: string;

  constructor(code: string, value: string) {
    this.code = code;
    this.value = value;
  }
}

export const commonFontColorMap: Map<string, CommonColorMapping> = new Map([
  ['Default', new CommonColorMapping('rgba(0, 246, 255, 1.0)', 'rgba(0, 246, 255, 1.0)')],
]);

export const highlightColorMap: Map<string, CommonColorMapping> = new Map([
  ['Default', new CommonColorMapping('rgba(0, 85, 255, 1.0)', 'rgba(0, 85, 255, 1.0)')],
]);

export class CommonFontWeightMapping {
  public readonly code: string;
  public readonly value: FontWeight;

  constructor(code: string, value: FontWeight) {
    this.code = code;
    this.value = value;
  }
}

export const fontWeightMapData: Map<string, CommonFontWeightMapping> = new Map([
  ['Normal', new CommonFontWeightMapping('FontWeight.Normal', FontWeight.Normal)],
  ['Lighter', new CommonFontWeightMapping('FontWeight.Lighter', FontWeight.Lighter)],
  ['Bolder', new CommonFontWeightMapping('FontWeight.Bolder', FontWeight.Bolder)],
  ['Default', new CommonFontWeightMapping('FontWeight.Normal', FontWeight.Normal)],
]);

export class CommonNumberMapping {
  public readonly code: string;
  public readonly value: number;

  constructor(code: string, value: number) {
    this.code = code;
    this.value = value;
  }
}

export class CommonStringMapping {
  public readonly code: string;
  public readonly value: string;

  constructor(code: string, value: string) {
    this.code = code;
    this.value = value;
  }
}

export class CommonBoolMapping {
  public readonly code: string;
  public readonly value: boolean;

  constructor(code: string, value: boolean) {
    this.code = code;
    this.value = value;
  }
}