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

import { TagEnum } from '@ohos/common';
import { BannerData, BaseData } from '@ohos/commonbusiness';
import { CardStyleTypeEnum, MediaTypeEnum } from '@ohos/commonbusiness';

@Observed
export class ComponentContent extends BaseData {
  public componentCardId: number = 0;
  public mediaType: MediaTypeEnum = MediaTypeEnum.IMAGE;
  public mediaUrl: string = '';
  public tagIds: TagEnum[] = [];
}

@Observed
export class ComponentCardData extends BaseData {
  public styleType: CardStyleTypeEnum = CardStyleTypeEnum.LIST;
  public image: string = '';
  public componentContents: ComponentContent[] = [];
  public themeColor: string = '';
}

export class ComponentData {
  public bannerInfos?: BannerData[];
  public cardData: ComponentCardData[] = [];
}