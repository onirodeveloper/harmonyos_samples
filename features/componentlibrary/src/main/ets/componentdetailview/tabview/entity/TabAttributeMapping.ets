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


import { CommonBoolMapping, CommonStringMapping } from '../../common/entity/CommonMapData';

type TabsValue = BarPosition | BlurStyle;

class TabsMapping {
  public code: string;
  public value: TabsValue;

  constructor(code: string, value: TabsValue) {
    this.code = code;
    this.value = value;
  }
}

export const barPositionMapData: Map<string, TabsMapping> = new Map([
  ['Default', new TabsMapping('BarPosition.Start', BarPosition.Start)],
  ['Start', new TabsMapping('BarPosition.Start', BarPosition.Start)],
  ['End', new TabsMapping('BarPosition.End', BarPosition.End)],
]);

export const blurStyleMapData: Map<string, TabsMapping> = new Map([
  ['Default', new TabsMapping('BlurStyle.NONE', BlurStyle.NONE)],
  ['None', new TabsMapping('BlurStyle.NONE', BlurStyle.NONE)],
  ['Thin', new TabsMapping('BlurStyle.Thin', BlurStyle.Thin)],
  ['Regular', new TabsMapping('BlurStyle.Regular', BlurStyle.Regular)],
  ['Thick', new TabsMapping('BlurStyle.Thick', BlurStyle.Thick)],
  ['BackgroundThin', new TabsMapping('BlurStyle.BACKGROUND_THIN', BlurStyle.BACKGROUND_THIN)],
  ['BackgroundRegular', new TabsMapping('BlurStyle.BACKGROUND_REGULAR', BlurStyle.BACKGROUND_REGULAR)],
  ['BackgroundThick', new TabsMapping('BlurStyle.BACKGROUND_THICK', BlurStyle.BACKGROUND_THICK)],
  ['BackgroundUltraThick', new TabsMapping('BlurStyle.BACKGROUND_ULTRA_THICK', BlurStyle.BACKGROUND_ULTRA_THICK)],
  ['ComponentThin', new TabsMapping('BlurStyle.COMPONENT_THIN', BlurStyle.COMPONENT_THIN)],
  ['ComponentUltraThin', new TabsMapping('BlurStyle.COMPONENT_ULTRA_THIN', BlurStyle.COMPONENT_ULTRA_THIN)],
  ['ComponentRegular', new TabsMapping('BlurStyle.COMPONENT_REGULAR', BlurStyle.COMPONENT_REGULAR)],
  ['ComponentUltraThick', new TabsMapping('BlurStyle.COMPONENT_ULTRA_THICK', BlurStyle.COMPONENT_ULTRA_THICK)],
  ['ComponentThick', new TabsMapping('BlurStyle.COMPONENT_THICK', BlurStyle.COMPONENT_THICK)],
]);

export const fadingEdgeMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('true', true)],
]);

export const verticalMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('false', false)],
]);

export const barWidthMapData: Map<string, CommonStringMapping> = new Map([
  ['Default', new CommonStringMapping('56vp', '56vp')],
]);

export const barHeightMapData: Map<string, CommonStringMapping> = new Map([
  ['Default', new CommonStringMapping('30vp', '30vp')],
]);