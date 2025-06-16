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

class TextInputTypeMap {
  public readonly code: string;
  public readonly value: InputType;

  constructor(code: string, value: InputType) {
    this.code = code;
    this.value = value;
  }
}

export const textInputTypeMapData: Map<string, TextInputTypeMap> = new Map([
  ['Normal', new TextInputTypeMap('InputType.Normal', InputType.Normal)],
  ['Number', new TextInputTypeMap('InputType.Number', InputType.Number)],
  ['NewPassword', new TextInputTypeMap('InputType.NEW_PASSWORD', InputType.NEW_PASSWORD)],
  ['Default', new TextInputTypeMap('InputType.Default', InputType.Normal)],
]);

class TextInputFontMap {
  public readonly code: string;
  public readonly value: Font;

  constructor(code: string, value: Font) {
    this.code = code;
    this.value = value;
  }
}

export const textInputFontMapData: Map<string, TextInputFontMap> = new Map([
  ['较细字体', new TextInputFontMap('{ size: $r(\'sys.float.Body_L\'), weight: FontWeight.Lighter}',
    { size: $r('sys.float.Body_L'), weight: FontWeight.Lighter })],
  ['正常字体', new TextInputFontMap('{ size: $r(\'sys.float.Body_L\'), weight: FontWeight.Regular }',
    { size: $r('sys.float.Body_L'), weight: FontWeight.Regular })],
  ['较粗字体', new TextInputFontMap('{ size: $r(\'sys.float.Body_L\'), weight: FontWeight.Bold }',
    { size: $r('sys.float.Body_L'), weight: FontWeight.Bold })],
  ['Default', new TextInputFontMap('{ size: $r(\'sys.float.Body_L\'), weight: FontWeight.Regular }',
    { size: $r('sys.float.Body_L'), weight: FontWeight.Regular })],
]);