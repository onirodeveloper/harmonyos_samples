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

export const ratingValueMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('0', 0)],
]);

export const starsMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('5', 5)]
]);

export const indicatorMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('false', false)],
]);

export const starStyleMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('false', false)],
]);