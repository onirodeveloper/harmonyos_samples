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

import { LoadingModel } from '@ohos/common';
import type { BannerData, } from '@ohos/commonbusiness';
import { CardStyleTypeEnum, CardTypeEnum, MediaTypeEnum } from '@ohos/commonbusiness';

export class SampleContent {
  public id: number = 0;
  public type: CardTypeEnum = CardTypeEnum.UNKNOWN;
  public mediaType: MediaTypeEnum = MediaTypeEnum.IMAGE;
  public mediaUrl: string = '';
  public title: string = '';
  public subTitle: string = '';
  public tags: string[] = [];
}

export class SampleCardData {
  public id: number = 0;
  public cardTitle: string = '';
  public cardSubTitle: string = '';
  public cardType: CardTypeEnum = CardTypeEnum.UNKNOWN;
  public cardStyleType: CardStyleTypeEnum = CardStyleTypeEnum.LIST;
  public cardImage: string = '';
  public version: string = '';
  public sampleContents: SampleContent[] = [];
  public detailCardId: number = 0;
}

@Observed
export class SampleCategory {
  public loadingModel: LoadingModel = new LoadingModel();
  public currentPage: number = 1;
  public id: number = 0;
  public categoryName: string = '';
  public categoryType: number = 0;
  public tabIcon: string = '';
  public tabIconSelected: string = '';
  public sampleCards: SampleCardData[] = [];
}

@Observed
export class SampleData {
  public bannerInfos?: BannerData[];
  public sampleCategories: SampleCategory[] = [];
}