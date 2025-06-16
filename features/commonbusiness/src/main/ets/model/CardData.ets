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

export class CardContent {
  public id: number = 0;
  public type: CardTypeEnum = CardTypeEnum.UNKNOWN;
  public mediaType: MediaTypeEnum = MediaTypeEnum.IMAGE;
  public mediaUrl: string = '';
  public title: string = '';
  public subTitle: string = '';
  public desc: string = '';
  public detailsUrl?: string = '';
  public originalUrl?: string = '';
}

export class CardData {
  public id: number = 0;
  public cardTitle: string = '';
  public cardSubTitle: string = '';
  public cardType: CardTypeEnum = CardTypeEnum.UNKNOWN;
  public cardStyleType: CardStyleTypeEnum = CardStyleTypeEnum.LIST;
  public cardImage: string = '';
  public version: string = '';
  public cardContents: CardContent[] = [];
}

export enum CardStyleTypeEnum {
  PICTURE_ABOVE_LIST = 1,
  LIST = 2,
  PICTURE = 3,
  PICTURE_ABOVE_TEXT = 4,
  PICTURE_TO_SWIPER = 5,
}

export enum MediaTypeEnum {
  IMAGE = 1,
  VIDEO = 2,
  SYMBOL = 3,
}

export enum CardTypeEnum {
  COMPONENT = 1,
  SAMPLE = 2,
  CODELAB = 3,
  ARTICLE = 4,
  UNKNOWN = 0,
}