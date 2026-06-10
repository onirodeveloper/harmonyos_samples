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
  public bundleName: string | null = null;
  public version: number = 0;
  public apiVersion: number = 0;
  public deviceType: string | null = null;
}

export class TrackServiceData {
  /**
   * The type of track, Click or Exposure.
   */
  public eventType: TrackEventType = TrackEventType.UNKNOWN;
  /**
   * The info of page.
   */
  public pageName?: string | null;
  /**
   * The info of tab click.
   */
  public mainTab?: MainTabEnum;
  public secondaryTab?: string;
  /**
   * The info of click item.
   */
  public interactionType?: string;
  public interactionContent?: string | null;
  public actionName?: string;
  /**
   *  The info of operation refer.
   */
  public referType?: ReferTypeEnum;
  public referSourceId?: number;
  /**
   * Other info.
   */
  public time: string = '';
  public duration?: number;
  public pushMessageTitle?: string;
}

export enum TrackEventType {
  UNKNOWN = 'UNKNOWN',
  CLICK = 'CLICK',
  EXPOSURE = 'EXPOSURE',
}

export enum MainTabEnum {
  COMPONENT = 'COMPONENT',
  SAMPLE = 'SAMPLE',
  ARTICLE = 'ARTICLE',
  MINE = 'MINE',
  UNKNOWN = '',
}

export enum InteractionTypeEnum {
  COMPONENT = 'COMPONENT',
  SAMPLE = 'SAMPLE',
  ARTICLE = 'ARTICLE',
  APPLICATION_UPDATE_DIALOG = 'APPLICATION_UPDATE_DIALOG',
}

export enum ReferTypeEnum {
  APPLICATION = 'APPLICATION',
  PUSH = 'PUSH',
  FORM_CARD = 'FORM_CARD',
  CELIA_SUGGESTION = 'CELIA_SUGGESTION',
  UNKNOWN = '',
}

export enum ActionName {
  /**
   * component module.
   */
  COMPONENT_CLICK = 'COMPONENT_CLICK',
  CODE_COPY = 'CODE_COPY',
  CODE_SHARE = 'CODE_SHARE',
  CODE_CLICK = 'CODE_CLICK',
  RECOMMEND_CLICK = 'RECOMMEND_CLICK',
  /**
   * sample module.
   */
  SAMPLE_CLICK = 'SAMPLE_CLICK',
  EXPERIENCE_CLICK = 'EXPERIENCE_CLICK',
  SOURCE_CODE_VIEW = 'SOURCE_CODE_VIEW',
  SOURCE_CODE_SHARE = 'SOURCE_CODE_SHARE',
  /**
   * article module.
   */
  ARTICLE_CLICK = 'ARTICLE_CLICK',
  /**
   * dialog action.
   */
  DIALOG_CANCEL = 'DIALOG_CANCEL',
  DIALOG_CONFIRM = 'DIALOG_CONFIRM',
  /**
   * error case.
   */
  UNKNOWN = 'UNKNOWN',
}