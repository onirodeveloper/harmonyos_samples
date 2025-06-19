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

import { CommonBoolMapping, CommonColorMapping } from '../../common/entity/CommonMapData';

type ToggleValue = ToggleType | ResourceColor ;

class ToggleTypeMapping {
  public readonly code: string;
  public readonly value: ToggleValue;

  constructor(code: string, value: ToggleValue) {
    this.code = code;
    this.value = value;
  }
}

export const toggleTypeMapData: Map<string, ToggleTypeMapping> = new Map([
  ['Default', new ToggleTypeMapping('ToggleType.Switch', ToggleType.Switch)],
  ['Switch', new ToggleTypeMapping('ToggleType.Switch', ToggleType.Switch)],
  ['Button', new ToggleTypeMapping('ToggleType.Button', ToggleType.Button)],
  ['Checkbox', new ToggleTypeMapping('ToggleType.Checkbox', ToggleType.Checkbox)],
]);

export const trackBorderRadiusMapData: Map<string, ToggleTypeMapping> = new Map([
  ['Default', new ToggleTypeMapping('16', $r('sys.float.ohos_id_corner_radius_default_l'))],
]);

export const isOnMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('true', true)],
]);

export const backgroundColorMapData: Map<string, CommonColorMapping> = new Map([
  ['Default', new CommonColorMapping('rgba(0,85,255)', 'rgba(0,85,255)')],
]);