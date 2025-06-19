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

import { CommonBoolMapping, CommonNumberMapping, CommonStringMapping } from '../../common/entity/CommonMapData';

const DATA_SIZE = 30;

@Observed
export class ItemData {
  public text: ResourceStr;
  public width: Resource | number;
  public height: Resource | number;

  constructor(text: ResourceStr = '', width: Resource | number = 0, height: Resource | number = 0) {
    this.text = text;
    this.width = width;
    this.height = height;
  }
}

export function getData() {
  const numbers: string[] = [];
  for (let i = 1; i <= DATA_SIZE; i++) {
    numbers.push(`item${i}`);
  }
  return numbers;
}

class ScrollMapping {
  public readonly code: string;
  public readonly value: Scroller;

  constructor(code: string, value: Scroller) {
    this.code = code;
    this.value = value;
  }
}

export const scrollerMapData: Map<string, ScrollMapping> = new Map([
  ['default', new ScrollMapping('new Scroller()', new Scroller())],
]);

export const columnsGapMapData: Map<string, CommonNumberMapping> = new Map([
  ['default', new CommonNumberMapping('10', 10)],
]);

export const rowsGapMapData: Map<string, CommonNumberMapping> = new Map([
  ['default', new CommonNumberMapping('10', 10)],
]);

export const columnsTemplateMapData: Map<string, CommonStringMapping> = new Map([
  ['default', new CommonStringMapping('1fr 1fr 1fr', '1fr 1fr 1fr')],
]);

export const rowsTemplateMapData: Map<string, CommonStringMapping> = new Map([
  ['default', new CommonStringMapping('1fr 1fr 1fr', '1fr 1fr 1fr')],
]);

export const operationModeMapData: Map<string, CommonBoolMapping> = new Map([
  ['default', new CommonBoolMapping('true', true)],
]);