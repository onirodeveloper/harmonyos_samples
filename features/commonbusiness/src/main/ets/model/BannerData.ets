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

import { MediaTypeEnum } from './CardData';

@Observed
export class BannerData {
  public id: number = 0;
  public bannerTitle: string = '';
  public bannerSubTitle: string = '';
  public bannerDesc: string = '';
  public bannerType: BannerTypeEnum = 0;
  public bannerValue: string = '';
  public mediaType: MediaTypeEnum = MediaTypeEnum.IMAGE;
  public mediaUrl: string = '';
  public detailsUrl: string = '';
  public tabViewType: number = -1;
}

export enum BannerTypeEnum {
  COMPONENT = 1,
  SAMPLE = 2,
  CODELAB = 3,
  ARTICLE = 4,
  UNKNOWN = 0,
}

// Banner magnification effect factor.
export const BANNER_SCALE_FACTOR: number = 3.00;
// Title magnification effect factor.
export const TITLE_SCALE_FACTOR: number = 6.00;