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

import { BusinessError } from '@kit.BasicServicesKit';
import {
  AccountService,
  Logger,
  PageContext,
  PageEnum,
  PreferenceManager,
  StorageKey,
  Toast,
  UserAccount,
} from '@ohos/common';
import { BaseHomeEventParam, BaseHomeEventType, BaseHomeViewModel, CardTypeEnum } from '@ohos/commonbusiness';
import { NewContentData } from '../model/NewContentData';
import { NewContentModel } from '../model/NewContentModel';
import { SettingViewBuilder } from '../view/SettingView';
import { BuilderEnum, ListGroup, MineItem, MinePageState } from './MinePageState';
import { QuestionnaireViewBuilder } from '../view/QuestionnaireView';

const TAG: string = '[MinePageVM]';

export class MinePageVM extends BaseHomeViewModel<MinePageState> {
  private static instance: MinePageVM;
  public listGroupData: ListGroup[] = [
    {
      id: 0,
      group: [
        {
          textContent: '',
          type: BuilderEnum.LOGIN_ITEM,
        } as MineItem
      ]
    },
    {
      id: 1,
      group: [
        {
          textContent: $r('app.string.user_experience'),
          subTextContent: $r('app.string.user_experience_tips'),
          symbolSrc: $r('app.media.userExperience'),
          type: BuilderEnum.USER_EXPERIENCE_CARD,
          builder: wrapBuilder(QuestionnaireViewBuilder),
        } as MineItem
      ]
    },
    {
      id: 2,
      group: [
        {
          textContent: $r('app.string.content_new'),
          symbolSrc: $r('sys.symbol.bell'),
          showTotalNum: true,
          onclick: () => {
            MinePageVM.getInstance().sendEvent<null>({
              type: MineEventType.JUMP_TO_NEW_CONTENT_PAGE,
              param: null,
            });
          },
          type: BuilderEnum.CARD_ITEM,
        } as MineItem,
        {
          textContent: $r('app.string.feedback'),
          symbolSrc: $r('sys.symbol.questionmark_circle'),
          type: BuilderEnum.CARD_ITEM,
          onclick: () => {
            Toast.showToast($r('app.string.feedback_desc'));
          },
        } as MineItem
      ]
    },
    {
      id: 3,
      group: [
        {
          textContent: $r('app.string.setting'),
          symbolSrc: $r('sys.symbol.gearshape'),
          type: BuilderEnum.CARD_ITEM,
          builder: wrapBuilder(SettingViewBuilder),
        } as MineItem
      ]
    }
  ]
  private model: NewContentModel = NewContentModel.getInstance();
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();

  private constructor() {
    super(new MinePageState());
  }

  public static getInstance() {
    if (!MinePageVM.instance) {
      MinePageVM.instance = new MinePageVM();
    }
    return MinePageVM.instance;
  }

  public sendEvent<T>(event: MineEventParam<T>): void | boolean {
    const eventType: MineEventType | BaseHomeEventType = event.type;
    if (eventType === MineEventType.JUMP_TO_NEW_CONTENT_PAGE) {
      this.jumpToNewContentPage();
    } else if (eventType === MineEventType.LOAD_CONTENT_NUMBER) {
      this.loadContentNumber();
    } else if (eventType === MineEventType.INIT_DATA) {
      this.assignData();
    } else if (eventType === MineEventType.LOGIN) {
      this.login();
    } else if (eventType === MineEventType.LOGOUT) {
      this.logout();
    } else if (eventType === MineEventType.UPDATE_ACCOUNT_DATA) {
      this.updateAccountData();
    } else {
      return super.sendEvent<T>(event as BaseHomeEventParam<T>);
    }
  }

  private assignData(): void {
    this.state.listItemData = this.listGroupData;
    this.updateAccountData();
  }

  private updateAccountData(): void {
    // close account confirmation dialog
    this.state.isShowAccountInfo = false;
    const userInfo = AccountService.getInstance().getUserInfo();
    if (userInfo) {
      this.state.avatarUrl = userInfo.avatarUrl;
      this.state.nickName = userInfo.nickname;
      this.state.isLogin = true;
    } else {
      this.state.avatarUrl = '';
      this.state.nickName = '';
      this.state.isLogin = false;
    }
  }

  private jumpToNewContentPage() {
    this.state.newContentNumber = 0;
    this.preferenceManager.setValue('hasViewedNewContent', true);
    const pageContext = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
      AppStorage.get<PageContext>(StorageKey.MINE_PAGE_CONTEXT) :
      AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    pageContext?.openPage({
      routerName: PageEnum.NEW_CONTENT_VIEW,
    }, true);
  }

  private loadContentNumber(): void {
    const hasResult: boolean = this.preferenceManager.hasValue('hasViewedNewContent');
    if (hasResult) {
      this.state.newContentNumber = 0;
    } else {
      Promise.all([this.getNewContent(CardTypeEnum.COMPONENT), this.getNewContent(CardTypeEnum.SAMPLE),
        this.getNewContent(CardTypeEnum.ARTICLE)]).then((result) => {
        this.state.newContentNumber = result.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
      })
    }
  }

  private getNewContent(type: CardTypeEnum): Promise<number> {
    return this.model.getNewContent(type)
      .then((res: NewContentData[]) => {
        return res.length;
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, ` getNewContent failed. Cause: message ${error.message}`);
        return 0;
      })
  }

  private login(): void {
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    if (!uiContext) {
      Logger.error(TAG, `login failed, cause uiContext or context is undefined.`);
      return;
    }
    AccountService.getInstance().login(uiContext)
      .then((userAccount: UserAccount) => {
        if (userAccount) {
          this.state.avatarUrl = userAccount.avatarUrl;
          this.state.nickName = userAccount.nickname;
          // Display account confirmation dialog
          this.state.isShowAccountInfo = true;
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, ` AccountService.getInstance().login failed. Cause: message ${err.message}`);
      });
  }

  private logout(): void {
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    if (!uiContext) {
      Logger.error(TAG, `logout failed, cause uiContext or context is undefined.`);
      return;
    }
    AccountService.getInstance().logout(uiContext)
      .then((isLogout: boolean) => {
        if (isLogout) {
          // Display account confirmation dialog
          this.state.isShowAccountInfo = true;
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, ` AccountService.getInstance().logout failed. Cause: message ${err.message}`);
      });
  }
}

export enum MineEventType {
  INIT_DATA = 'initData',
  LOAD_CONTENT_NUMBER = 'loadContentNumber',
  LOGIN = 'login',
  LOGOUT = 'logout',
  UPDATE_ACCOUNT_DATA = 'updateAccountData',
  JUMP_TO_NEW_CONTENT_PAGE = 'jumpToNewContentPage',
}

export interface MineEventParam<T> {
  type: MineEventType | BaseHomeEventType;
  param: T;
}