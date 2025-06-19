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

export enum ElementsNums {
  TWO = '2',
  FOUR = '4',
}

type FlexValueType = FlexDirection | FlexWrap | FlexAlign | ItemAlign | ElementsNums;

class FlexDictionaryMapping {
  public readonly code: string;
  public readonly value: FlexValueType;

  constructor(code: string, value: FlexValueType) {
    this.code = code;
    this.value = value;
  }
}

export const flexDirectionMapData: Map<string, FlexDictionaryMapping> = new Map([
  ['Default', new FlexDictionaryMapping('FlexDirection.Row', FlexDirection.Row)],
  ['Row', new FlexDictionaryMapping('FlexDirection.Row', FlexDirection.Row)],
  ['RowReverse', new FlexDictionaryMapping('FlexDirection.RowReverse', FlexDirection.RowReverse)],
  ['Column', new FlexDictionaryMapping('FlexDirection.Column', FlexDirection.Column)],
  ['ColumnReverse', new FlexDictionaryMapping('FlexDirection.ColumnReverse', FlexDirection.ColumnReverse)],
]);

export const flexWrapMapData: Map<string, FlexDictionaryMapping> = new Map([
  ['Default', new FlexDictionaryMapping('FlexWrap.NoWrap', FlexWrap.NoWrap)],
  ['NoWrap', new FlexDictionaryMapping('FlexWrap.NoWrap', FlexWrap.NoWrap)],
  ['Wrap', new FlexDictionaryMapping('FlexWrap.Wrap', FlexWrap.Wrap)],
  ['WrapReverse', new FlexDictionaryMapping('FlexWrap.WrapReverse', FlexWrap.WrapReverse)],
]);

export const flexContentMapData: Map<string, FlexDictionaryMapping> = new Map([
  ['Default', new FlexDictionaryMapping('FlexAlign.Start', FlexAlign.Start)],
  ['Start', new FlexDictionaryMapping('FlexAlign.Start', FlexAlign.Start)],
  ['Center', new FlexDictionaryMapping('FlexAlign.Center', FlexAlign.Center)],
  ['End', new FlexDictionaryMapping('FlexAlign.End', FlexAlign.End)],
  ['SpaceBetween', new FlexDictionaryMapping('FlexAlign.SpaceBetween', FlexAlign.SpaceBetween)],
  ['SpaceAround', new FlexDictionaryMapping('FlexAlign.SpaceAround', FlexAlign.SpaceAround)],
  ['SpaceEvenly', new FlexDictionaryMapping('FlexAlign.SpaceEvenly', FlexAlign.SpaceEvenly)],
]);

export const flexAlignItemMapData: Map<string, FlexDictionaryMapping> = new Map([
  ['Default', new FlexDictionaryMapping('ItemAlign.Auto', ItemAlign.Auto)],
  ['Auto', new FlexDictionaryMapping('ItemAlign.Auto', ItemAlign.Auto)],
  ['Start', new FlexDictionaryMapping('ItemAlign.Start', ItemAlign.Start)],
  ['Center', new FlexDictionaryMapping('ItemAlign.Center', ItemAlign.Center)],
  ['End', new FlexDictionaryMapping('ItemAlign.End', ItemAlign.End)],
  ['Stretch', new FlexDictionaryMapping('ItemAlign.Stretch', ItemAlign.Stretch)],
  ['Baseline', new FlexDictionaryMapping('ItemAlign.Baseline', ItemAlign.Baseline)],
]);

export const elementsNumsMapData: Map<string, FlexDictionaryMapping> = new Map([
  ['Default', new FlexDictionaryMapping('2', ElementsNums.TWO)],
]);