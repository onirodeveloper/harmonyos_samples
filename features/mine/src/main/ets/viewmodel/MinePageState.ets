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

import { ObservedArray } from '@ohos/common';
import { BaseHomeState } from '@ohos/commonbusiness';

@Observed
export class MinePageState extends BaseHomeState {
  public newContentNumber: number = 0;
  public listItemData: ListGroup[] = [];
  public isLogin: boolean = false;
  public isShowAccountInfo: boolean = false;
  public nickName: string = '';
  public avatarUrl: string = '';
}

@Observed
export class ListGroup {
  public id: number = 0;
  public group: ObservedArray<MineItem> = [];
}

@Observed
export class MineItem {
  public textContent: ResourceStr = '';
  public subTextContent?: ResourceStr = '';
  public symbolSrc?: Resource = $r('sys.symbol.bell');
  public showTotalNum?: boolean = false;
  public type: BuilderEnum = BuilderEnum.USER_EXPERIENCE_CARD;
  public builder?: WrappedBuilder<[]>;
  public onclick?: Function = () => {
  };
}

export enum BuilderEnum {
  USER_EXPERIENCE_CARD = 'UserExperienceCardItem',
  CARD_ITEM = 'CardItem',
  LOGIN_ITEM = 'LoginItem'
}