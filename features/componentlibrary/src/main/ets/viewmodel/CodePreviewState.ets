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

import { BaseState } from '@ohos/common';

@Observed
export class CodePreviewState extends BaseState {
  public topTranslateY: number;
  public bottomTranslateY: number;
  public navigationOpacity: number;

  constructor(topTranslateY: number, bottomTranslateY: number, navigationOpacity: number) {
    super();
    this.topTranslateY = topTranslateY;
    this.bottomTranslateY = bottomTranslateY;
    this.navigationOpacity = navigationOpacity;
  }
}