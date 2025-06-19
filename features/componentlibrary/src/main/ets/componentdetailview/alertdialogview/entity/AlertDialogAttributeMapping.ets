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

import { CommonNumberMapping } from '../../common/entity/CommonMapData';

class DialogAlignmentMapping {
  public readonly code: string;
  public readonly value: DialogAlignment;

  constructor(code: string, value: DialogAlignment) {
    this.code = code;
    this.value = value;
  }
}

export const alertDialogAlignmentMapData: Map<string, DialogAlignmentMapping> = new Map([
  ['Default', new DialogAlignmentMapping('DialogAlignment.Default', DialogAlignment.Default)],
  ['Top', new DialogAlignmentMapping('DialogAlignment.Top', DialogAlignment.Top)],
  ['Center', new DialogAlignmentMapping('DialogAlignment.Center', DialogAlignment.Center)],
  ['Bottom', new DialogAlignmentMapping('DialogAlignment.Bottom', DialogAlignment.Bottom)],
]);