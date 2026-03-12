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

export const TRACK_KEY = 'HMOS_TRACK_SERVICE';

export class PostTrackModel {
  public trackData: TrackModel[] = [];
}

/**
 * TrackModel: the track data, includes common data and service data.
 */
export class TrackModel {
  public trackCommonData: TrackCommonData;
  public trackServiceData: TrackServiceData;

  constructor(trackCommonData: TrackCommonData, trackServiceData: TrackServiceData) {
    this.trackCommonData = trackCommonData;
    this.trackServiceData = trackServiceData;
  }
}

export class TrackCommonData {
  public bundleName: string = '';
  public version: number = 0;
  public apiVersion: number = 0;
  public deviceType: string = '';
}

export class TrackServiceData {
  public moduleType: number = 0;
  public eventType: TrackEventType = TrackEventType.UNKNOWN;
  public operTime: string = '';
  public content: string = '';
  public ownerPage: string = '';
}

export enum TrackEventType {
  COMPONENT_CLICK = 'COMPONENT_CLICK',
  COMPONENT_EXPOSURE = 'COMPONENT_EXPOSURE',
  COMPONENT_CODE_CLICK = 'COMPONENT_CODE_CLICK',
  COMPONENT_CODE_COPY_CLICK = 'COMPONENT_CODE_COPY_CLICK',
  COMPONENT_CODE_SHARE_CLICK = 'COMPONENT_CODE_SHARE_CLICK',
  COMPONENT_RECOMMEND_CLICK = 'COMPONENT_RECOMMEND_CLICK',
  SAMPLE_CLICK = 'SAMPLE_CLICK',
  SAMPLE_EXPOSURE = 'SAMPLE_EXPOSURE',
  SAMPLE_EXPERIENCE_CLICK = 'SAMPLE_EXPERIENCE_CLICK',
  SAMPLE_SOURCECODE_READ_CLICK = 'SAMPLE_SOURCECODE_READ_CLICK',
  SAMPLE_SOURCECODE_SHARE_CLICK = 'SAMPLE_SOURCECODE_SHARE_CLICK',
  ARTICLE_CLICK = 'ARTICLE_CLICK',
  ARTICLE_EXPOSURE = 'ARTICLE_EXPOSURE',
  UNKNOWN = 'UNKNOWN'
}