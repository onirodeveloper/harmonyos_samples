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

import { CommonColorMapping, CommonNumberMapping } from '../../common/entity/CommonMapData';

class TextMapping {
  public readonly code: string;
  public readonly value: Length;

  constructor(code: string, value: Length) {
    this.code = code;
    this.value = value;
  }
}

export const fontSizeMapData: Map<string, TextMapping> = new Map([
  ['Default', new TextMapping('16', $r('sys.float.ohos_id_text_size_body1'))],
]);

export const fontColorMapData: Map<string, CommonColorMapping> = new Map([
  ['Default', new CommonColorMapping('rgba(0,85,255)', 'rgba(0,85,255)')],
]);

export const opacityMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('1', 1)],
]);

export const letterSpacingMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('0', 0)],
]);

export const textShadowRadiusMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('0', 0)],
]);