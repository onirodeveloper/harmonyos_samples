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

import type { TopNavigationData } from '@ohos/common';
import { BaseState, LoadingStatus } from '@ohos/common';
import { NewContentData } from '../model/NewContentData';

@Observed
export class NewContentPageState extends BaseState {
  public topNavigationData: TopNavigationData;
  public loadingStatus: LoadingStatus;
  public newComponentData: NewContentData[] = [];
  public newSampleData: NewContentData[] = [];
  public newArticleData: NewContentData[] = [];
  public isBackPressed: boolean = false;

  constructor(
    loadingStatus: LoadingStatus,
    topNavigationData: TopNavigationData,
  ) {
    super();
    this.loadingStatus = loadingStatus;
    this.topNavigationData = topNavigationData;
  }
}