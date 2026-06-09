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
import { StorageKey } from '../constant';
import { CallMethod, ENTRY_ABILITY, FormCardAction } from '../constant/FormCardConstant';
import { WantParams } from '../util';

class ActionUtils {
  public updateControlCardAction(component: Object, formId: string) {
    postCardAction(component, {
      action: FormCardAction.CALL,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.REQUEST_UPDATE_CARD,
        formId: formId
      },
    });
  }

  /** this function call up main app with a want and designate a target tab page to jump to */
  jumpToPage(component: Object, tabBarType: TabBarType = TabBarType.SAMPLE) {
    let shorCutKey: ShortCutKey = ShortCutKey.COMPONENT_LIST;
    switch (tabBarType) {
      case TabBarType.HOME:
        shorCutKey = ShortCutKey.COMPONENT_LIST;
        break;
      case TabBarType.SAMPLE:
        shorCutKey = ShortCutKey.SAMPLE_LIST;
        break;
      case TabBarType.PRACTICE:
        shorCutKey = ShortCutKey.ARTICLE_LIST;
        break;
      case TabBarType.MINE:
        shorCutKey = ShortCutKey.MINE_PAGE;
        break;
      default:
        shorCutKey = ShortCutKey.COMPONENT_LIST;
    }
    postCardAction(component, {
      action: FormCardAction.ROUTER,
      abilityName: ENTRY_ABILITY,
      params: {
        'type': RouteType.None,
        'isFromShortCut': 'true',
        'shortCutKey': shorCutKey,
      },
    });
  }

  jumpApp(component: Object) {
    postCardAction(component, {
      action: FormCardAction.CALL,
      abilityName: ENTRY_ABILITY,
    });
  }
}

export default new ActionUtils();

enum TabBarType {
  HOME = 0,
  SAMPLE = 1,
  PRACTICE = 2,
  MINE = 3,
}

enum ShortCutKey {
  COMPONENT_LIST = 'ComponentListPage',
  SAMPLE_LIST = 'SampleListPage',
  ARTICLE_LIST = 'ArticleListPage',
  MINE_PAGE = 'MinePage',
}