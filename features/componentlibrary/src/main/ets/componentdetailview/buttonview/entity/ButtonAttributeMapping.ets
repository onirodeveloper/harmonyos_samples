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

import { CommonColorMapping } from '../../common/entity/CommonMapData';

class ButtonStyleMapping {
 public code: string;
 public value: ButtonStyleMode;

  constructor(code: string, value: ButtonStyleMode) {
    this.code = code;
    this.value = value;
  }
}

class ControlSizeMapping {
  public code: string;
  public value: ControlSize;

  constructor(code: string, value: ControlSize) {
    this.code = code;
    this.value = value;
  }
}

class ButtonTypeMapping {
  public code: string;
  public value: ButtonType;

  constructor(code: string, value: ButtonType) {
    this.code = code;
    this.value = value;
  }
}

class ButtonActionMapping {
  public code: string;
  public value: string;

  constructor(code: string, value: string) {
    this.code = code;
    this.value = value;
  }
}

export const styleMapData: Map<string, ButtonStyleMapping> = new Map([
  ['Normal', new ButtonStyleMapping('ButtonStyleMode.NORMAL', ButtonStyleMode.NORMAL)],
  ['Emphasized', new ButtonStyleMapping('ButtonStyleMode.EMPHASIZED', ButtonStyleMode.EMPHASIZED)],
  ['Textual', new ButtonStyleMapping('ButtonStyleMode.TEXTUAL', ButtonStyleMode.TEXTUAL)],
  ['Default', new ButtonStyleMapping('ButtonStyleMode.EMPHASIZED', ButtonStyleMode.EMPHASIZED)],
]);

export const sizeMapData: Map<string, ControlSizeMapping> = new Map([
  ['Normal', new ControlSizeMapping('ControlSize.NORMAL', ControlSize.NORMAL)],
  ['Small', new ControlSizeMapping('ControlSize.SMALL', ControlSize.SMALL)],
  ['Default', new ControlSizeMapping('ControlSize.SMALL', ControlSize.SMALL)],
]);

export const buttonTypeMapData: Map<string, ButtonTypeMapping> = new Map([
  ['Capsule', new ButtonTypeMapping('ButtonType.Capsule', ButtonType.Capsule)],
  ['Normal', new ButtonTypeMapping('ButtonType.Normal', ButtonType.Normal)],
  ['Default', new ButtonTypeMapping('ButtonType.Capsule', ButtonType.Capsule)],
]);

export const buttonBgColorMap: Map<string, CommonColorMapping> = new Map([
  ['Default', new CommonColorMapping('rgb(255, 255, 255)', 'rgb(255, 255, 255)')],
]);

export const buttonActionMap: Map<string, ButtonActionMapping> = new Map([
  ['Click', new ButtonActionMapping('Click', 'Click')],
  ['LongGesture', new ButtonActionMapping('LongGesture', 'LongGesture')],
  ['Default', new ButtonActionMapping('Click', 'Click')],
]);