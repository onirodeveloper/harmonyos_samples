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

import { LoadingModel, TagEnum } from '@ohos/common';
import { BannerData, BaseData, } from '@ohos/commonbusiness';
import { CardStyleTypeEnum } from '@ohos/commonbusiness';

export class SampleContent extends BaseData {
  public type: SampleTypeEnum = SampleTypeEnum.UNKNOWN;
  public tags: string[] = [];
  public tagIds: TagEnum[] = [];
  public cardId: number = 0;
  public unionId: number = 0;
  public mediaInfoList: MediaInfo[] = [];
}

export class MediaInfo {
  public id: number = 0;
  public mediaUrl: string = '';
  public mediaDescription: string = '';
  public sequence: number = 0;
}

export class SampleCardData extends BaseData {
  public styleType: CardStyleTypeEnum = CardStyleTypeEnum.LIST;
  public image: string = '';
  public sampleContents: SampleContent[] = [];
  public unionId: number = 0;
}

@Observed
export class SampleCategory {
  public loadingModel: LoadingModel = new LoadingModel();
  public currentPage: number = 1;
  public id: number = 0;
  public categoryName: string = '';
  public defaultIcon: string = '';
  public selectedIcon: string = '';
  public sampleCards: SampleCardData[] = [];
  public sequence: number = 0;
}

@Observed
export class SampleData {
  public bannerInfos?: BannerData[];
  public sampleCategories: SampleCategory[] = [];
}

export enum SampleTypeEnum {
  COMMON_CLIENT = 'commonClient',
  WEARABLE_CLIENT = 'wearableClient',
  COMMON_SAMPLE = 'commonSample',
  UNKNOWN = 'unknown',
}
