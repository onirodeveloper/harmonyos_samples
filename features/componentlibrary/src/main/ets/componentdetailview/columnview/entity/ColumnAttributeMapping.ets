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

class ColumnAlignMapping {
  public readonly code: string;
  public readonly value: HorizontalAlign;

  constructor(code: string, value: HorizontalAlign) {
    this.code = code;
    this.value = value;
  }
}

export const columnAlignMapData: Map<string, ColumnAlignMapping> = new Map([
  ['Start', new ColumnAlignMapping('HorizontalAlign.Start', HorizontalAlign.Start)],
  ['Center', new ColumnAlignMapping('HorizontalAlign.Center', HorizontalAlign.Center)],
  ['End', new ColumnAlignMapping('HorizontalAlign.End', HorizontalAlign.End)],
  ['Default', new ColumnAlignMapping('HorizontalAlign.Center', HorizontalAlign.Center)],
]);

export const columnSpaceMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('3', 3)],
]);

export const columnPaddingMapData: Map<string, CommonStringMapping> = new Map([
  ['Vertical', new CommonStringMapping('Vertical', 'Vertical')],
  ['Horizontal', new CommonStringMapping('Horizontal', 'Horizontal')],
  ['All', new CommonStringMapping('All', 'All')],
  ['None', new CommonStringMapping('None', 'None')],
  ['Default', new CommonStringMapping('All', 'All')],
]);

export const paddingNumMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('3', 3)],
]);