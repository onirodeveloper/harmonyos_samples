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

import { CommonNumberMapping, CommonStringMapping } from '../../common/entity/CommonMapData';

class FlexDirectionMapping {
  public code: string;
  public value: FlexDirection;

  constructor(code: string, value: FlexDirection) {
    this.code = code;
    this.value = value;
  }
}

export const layoutDirectionMapData: Map<string, FlexDirectionMapping> = new Map([
  ['Default', new FlexDirectionMapping('FlexDirection.Column', FlexDirection.Column)],
  ['Column', new FlexDirectionMapping('FlexDirection.Column', FlexDirection.Column)],
  ['Row', new FlexDirectionMapping('FlexDirection.Row', FlexDirection.Row)],
  ['RowReverse', new FlexDirectionMapping('FlexDirection.RowReverse', FlexDirection.RowReverse)],
  ['ColumnReverse', new FlexDirectionMapping('FlexDirection.ColumnReverse', FlexDirection.ColumnReverse)],
]);

export const frictionMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('0.75', 0.75)],
  ['0.1', new CommonNumberMapping('0.1', 0.1)],
  ['0.6', new CommonNumberMapping('0.6', 0.6)],
  ['0.75', new CommonNumberMapping('0.75', 0.75)],
  ['0.9', new CommonNumberMapping('0.9', 0.9)],
]);

export const columnsTemplateMapData: Map<string, CommonStringMapping> = new Map([
  ['Default', new CommonStringMapping('1fr', '1fr')],
]);

export const rowsTemplateMapData: Map<string, CommonStringMapping> = new Map([
  ['Default', new CommonStringMapping('1fr', '1fr')],
]);

export const columnsGapMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('0', 0)],
]);