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

import { CommonBoolMapping, CommonNumberMapping } from '../../common/entity/CommonMapData';

export const itemHeightMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('56', 56)],
])

export const canLoopMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('true', true)],
])

export const pickerData: string[] = ['apple', 'orange', 'peach', 'grape', 'banana'];

export const pickerDataCode: string = `['apple', 'orange', 'peach', 'grape', 'banana']`;