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

import { HdsTabsController } from '@kit.UIDesignKit';
import { InteractionTypeEnum } from '@ohos/common';

interface BasicRouterParams {
  title: string;
  id: number;
}

export interface ComponentDetailParams extends BasicRouterParams {
  interactionType: InteractionTypeEnum;
}

export interface SampleDetailParams extends BasicRouterParams {
  currentIndex: number;
  cardId: number;
  unionId: number;
  interactionType: InteractionTypeEnum;
  categoryName?: string;
}

export interface ArticleDetailParams extends BasicRouterParams {
  isArticle: boolean;
  detailsUrl: string;
  desc: string;
  tabViewType?: number;
  interactionType: InteractionTypeEnum;
}

export interface CodeViewParams {
  code: string;
  componentName: string;
  // preFinishAnimation: () => void;
}

export interface HomeListParams {
  scroller: Scroller,
  homeTabController: HdsTabsController
}