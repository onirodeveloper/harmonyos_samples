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

import { Want } from '@kit.AbilityKit';
import { StorageKey } from '../constant/CommonEnums';
import { ArticleListItem, FormCardEnum } from '../model/FormCardInfo';
import { PageContext } from '../routermanager/PageContext';
import Logger from './Logger';

const TAG: string = 'PullUpManager';

export class PullUpManager {
  private static formCardType?: FormCardEnum;

  /**
   * try to start app ability from outside.
   *
   * @param want
   * @returns void
   */
  public static pullUpApp(want: Want): void {
    if (!PullUpManager.checkAndHandleParams(want)) {
      return;
    }
    if (PullUpManager.isShortCutPullUp(want)) {
      AppStorage.setOrCreate<WantParams>(StorageKey.WANT_PARAMETERS, want.parameters);
      PullUpManager.navigationToHome();
    } else if (PullUpManager.isFromFormCard()) {
      try {
        AppStorage.setOrCreate<WantParams>(StorageKey.WANT_PARAMETERS,
          JSON.parse(want.parameters?.['params'] as string));
      } catch (error) {
        Logger.error(TAG, `Parse fail, cause: ${error}`);
      }
      PullUpManager.navigationToHome();
    }
  }

  /**
   * Get the different form card from, if 'ARTICLE_SERVICE_CARD', then entryAbility invoke the update.
   *
   * @param want
   * @returns FormCardEnum or void.
   */
  public static getFormCardType(want: Want): FormCardEnum | void {
    // The serviceCard and Lock screen card all has formID. Short cut entry doesn't has formID.
    if (want.parameters && want.parameters?.['formID'] && want.parameters['params']) {
      try {
        const cardWantParams: WantParams = JSON.parse(want.parameters['params'] as string);
        const cardFrom: FormCardEnum = Reflect.get(cardWantParams, 'cardFrom') as FormCardEnum;
        PullUpManager.formCardType = cardFrom;
        return cardFrom;
      } catch (err) {
        Logger.error(TAG, `The getFormCardType occur error: ${err}}`)
      }
    }
    // Reset the PullUpManager.FormCardType.
    PullUpManager.formCardType = undefined;
  }

  private static checkAndHandleParams(want: Want): boolean {
    try {
      if (want === undefined || want === null || want.parameters === undefined || want.parameters === null) {
        return false;
      }
    } catch (err) {
      Logger.error(TAG, `checkAndHandleParams failed: ${err}`);
    }
    return true;
  }

  private static isShortCutPullUp(want: Want): boolean {
    if (want.parameters) {
      const isFromShortCut: string = Reflect.get(want.parameters, 'isFromShortCut') as string;
      return isFromShortCut === 'true';
    }
    return false;
  }

  private static isFromFormCard() {
    return PullUpManager.formCardType === FormCardEnum.ARTICLE_SERVICE_CARD ||
      PullUpManager.formCardType === FormCardEnum.LOCK_SCREEN_CARD ||
      PullUpManager.formCardType === FormCardEnum.LOCK_SCREEN_CARD_LG;
  }

  private static navigationToHome(): void {
    const pageContext: PageContext | undefined = AppStorage.get(StorageKey.HOME_PAGE_CONTEXT);
    const componentPageContext: PageContext | undefined = AppStorage.get(StorageKey.COMPONENT_PAGE_CONTEXT);
    const samplePageContext: PageContext | undefined = AppStorage.get(StorageKey.SAMPLE_PAGE_CONTEXT);
    const explorationPageContext: PageContext | undefined = AppStorage.get(StorageKey.EXPLORATION_PAGE_CONTEXT);
    const minePageContext: PageContext | undefined = AppStorage.get(StorageKey.MINE_PAGE_CONTEXT);
    pageContext?.popPageByIndex(0);
    // Adapt the PC situation.
    componentPageContext?.clear();
    samplePageContext?.clear();
    explorationPageContext?.clear();
    minePageContext?.clear();
  }
}

export class WantParams {
  /**
   * Short cut entry point.
   */
  public shortCutKey?: string = '';
  public isFromShortCut?: string = '';
  /**
   * Service Card.
   */
  public formId?: string;
  public cardFrom?: FormCardEnum;
  public articleInfo?: ArticleListItem;
}