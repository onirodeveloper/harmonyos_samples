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

import { BaseState, LoadingStatus } from '@ohos/common';
import { SampleTypeEnum } from '../common/SampleConstant';

@Observed
export class SampleDetailState extends BaseState {
  public sampleDatas: SampleDetailData[] = [];
  public sampleCount: number = 0;
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;
  public taskId?: string = '';
  public currentIndex: number = 0;
  public installingStatus: boolean = false;
  public downloadingStatus: boolean = false;
  public isBackPressed: boolean = false;
}

@Observed
export class SampleDetailData {
  public id: number = 0;
  public isFavorite: boolean = false;
  public mediaType: number = 0;
  public mediaUrl: string = '';
  public sampleCard: SampleCardData = new SampleCardData();
}

@Observed
export class SampleCardData {
  public title: string = '';
  public desc: string = '';
  public sampleType: SampleTypeEnum = SampleTypeEnum.COMMON_SAMPLE;
  public sampleId: number = 0;
  public originalUrl: string = '';
  public moduleName: string = '';
  public abilityName: string = '';
  public bindSheetShow: boolean = false;
  public downloading: boolean = false;
  public downloadProgress: number = -1;
  public installed: boolean = false;
}