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

class StackAlignMapping {
  public readonly code: string;
  public readonly value: Alignment;

  constructor(code: string, value: Alignment) {
    this.code = code;
    this.value = value;
  }
}

export const stackAlignMapData: Map<string, StackAlignMapping> = new Map([
  ['Top', new StackAlignMapping('Alignment.Top', Alignment.Top)],
  ['TopStart', new StackAlignMapping('Alignment.TopStart', Alignment.TopStart)],
  ['TopEnd', new StackAlignMapping('Alignment.TopEnd', Alignment.TopEnd)],
  ['Start', new StackAlignMapping('Alignment.Start', Alignment.Start)],
  ['Center', new StackAlignMapping('Alignment.Center', Alignment.Center)],
  ['End', new StackAlignMapping('Alignment.End', Alignment.End)],
  ['BottomStart', new StackAlignMapping('Alignment.BottomStart', Alignment.BottomStart)],
  ['BottomEnd', new StackAlignMapping('Alignment.BottomEnd', Alignment.BottomEnd)],
  ['Bottom', new StackAlignMapping('Alignment.Bottom', Alignment.Bottom)],
  ['Default', new StackAlignMapping('Alignment.Center', Alignment.Center)],
]);