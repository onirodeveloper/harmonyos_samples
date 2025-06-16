/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { BaseState, LoadingModel } from '@ohos/common';
import { FullScreenNavigationData } from '../model/FullScreenNavigationData';
import { BannerSource } from './BannerSource';

@Observed
export class BaseHomeState extends BaseState {
  public loadingModel: LoadingModel = new LoadingModel();
  public topNavigationData: FullScreenNavigationData = new FullScreenNavigationData();
  public currentScrollState: ScrollState = ScrollState.Idle;
  public bannerState: BannerState = new BannerState();
  public bannerHeight: number = 0;
  public currentPage: number = 1;
  public hasEdgeEffect: boolean = false;

  public constructor() {
    super();
  }
}

@Observed
export class BannerState {
  public bannerHeight: number = 0;
  public bannerResource: BannerSource = new BannerSource();
}