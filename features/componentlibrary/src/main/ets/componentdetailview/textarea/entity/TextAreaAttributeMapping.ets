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

class TextOverflowTypeMap {
  public readonly code: string;
  public readonly value: TextOverflow;

  constructor(code: string, value: TextOverflow) {
    this.code = code;
    this.value = value;
  }
}

export const textOverflowTypeMapData: Map<string, TextOverflowTypeMap> = new Map([
  ['None', new TextOverflowTypeMap('TextOverflow.None', TextOverflow.None)],
  ['Clip', new TextOverflowTypeMap('TextOverflow.Clip', TextOverflow.Clip)],
  ['Ellipsis', new TextOverflowTypeMap('TextOverflow.Ellipsis', TextOverflow.Ellipsis)],
  ['Marquee', new TextOverflowTypeMap('TextOverflow.MARQUEE', TextOverflow.MARQUEE)],
  ['Default', new TextOverflowTypeMap('TextOverflow.Clip', TextOverflow.Clip)],
]);

class TextAlignTypeMap {
  public readonly code: string;
  public readonly value: TextAlign;

  constructor(code: string, value: TextAlign) {
    this.code = code;
    this.value = value;
  }
}

export const textAlignTypeMapData: Map<string, TextAlignTypeMap> = new Map([
  ['Start', new TextAlignTypeMap('TextAlign.Start', TextAlign.Start)],
  ['Center', new TextAlignTypeMap('TextAlign.Center', TextAlign.Center)],
  ['End', new TextAlignTypeMap('TextAlign.End', TextAlign.End)],
  ['Justify', new TextAlignTypeMap('TextAlign.JUSTIFY', TextAlign.JUSTIFY)],
  ['Default', new TextAlignTypeMap('TextAlign.Start', TextAlign.Start)],
]);