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

import { SampleTypeEnum } from '../common/SampleConstant';
import { MediaInfo } from './SampleData';

export class SingleSampleData {
  public id: number = 0;
  public title: string = '';
  public desc: string = '';
  public preInstalled: boolean = false;
  public type: SampleTypeEnum = SampleTypeEnum.COMMON_SAMPLE;
  public isFavorite: boolean = false;
  public mediaInfoList: MediaInfo[] = [];
  public originalUrl: string = '';
  public moduleName: string = '';
  public abilityName: string = '';
  public apiVersion: number = 0;
  public supportDeviceList: string[] = [];
}

export class SampleCardDetail {
  public id: number = 0;
  public categoryId: number = 0;
  public sampleDetail: SingleSampleData[] = [];
}