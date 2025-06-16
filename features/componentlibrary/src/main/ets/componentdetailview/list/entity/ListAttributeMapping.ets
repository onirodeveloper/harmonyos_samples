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

class ListDirectionType {
  public readonly code: string;
  public readonly value: Axis;

  constructor(code: string, value: Axis) {
    this.code = code;
    this.value = value;
  }
}

export const listDirectionMapData: Map<string, ListDirectionType> = new Map([
  ['Vertical', new ListDirectionType('Axis.Vertical', Axis.Vertical)],
  ['Horizontal', new ListDirectionType('Axis.Horizontal', Axis.Horizontal)],
  ['Default', new ListDirectionType('Axis.Vertical', Axis.Vertical)],
]);

class EdgeEffectMap {
  public readonly code: string;
  public readonly value: EdgeEffect;

  constructor(code: string, value: EdgeEffect) {
    this.code = code;
    this.value = value;
  }
}

export const edgeEffectMapData: Map<string, EdgeEffectMap> = new Map([
  ['Spring', new EdgeEffectMap('EdgeEffect.Spring', EdgeEffect.Spring)],
  ['Fade', new EdgeEffectMap('EdgeEffect.Fade', EdgeEffect.Fade)],
  ['None', new EdgeEffectMap('EdgeEffect.None', EdgeEffect.None)],
  ['Default', new EdgeEffectMap('EdgeEffect.Spring', EdgeEffect.Spring)],
]);

export interface TimeTable {
  title: string;
  projects: string[];
}

export interface LanesStyle {
  value: number;
  gutter: Dimension;
}

export const timeTable: TimeTable[] = [
  {
    title: 'ONE',
    projects: ['item 1', 'item 2', 'item 3', 'item 4'],
  },
  {
    title: 'TWO',
    projects: ['item 5', 'item 6', 'item 7', 'item 8'],
  },
  {
    title: 'THREE',
    projects: ['item 9', 'item 10', 'item 11', 'item 12'],
  },
  {
    title: 'FOUR',
    projects: ['item 13', 'item 14', 'item 15', 'item 16'],
  },
];
