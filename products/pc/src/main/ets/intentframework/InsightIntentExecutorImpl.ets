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
import { insightIntent, InsightIntentExecutor } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import {
  PageContext,
  StorageKey,
  Toast,
  Logger,
  WantParams,
  INTENT_XIAOYI_DEFAULT_VALUE,
} from '@ohos/common';
import {
  IntentJsonEnumDetail,
  IntentInfo,
} from '@ohos/common/src/main/ets/model/IntentDataModel';
import { IntentNameEnum } from '@ohos/common/src/main/ets/constant/IntentEnums';
import { FuzzyMatch, RawfileIO } from '@ohos/common/src/main/ets/util/FuzzyMatchUtil';
import { InsightIntentViewModel } from '@ohos/commonbusiness/src/main/ets/viewmodel/InsightIntentViewModel';
import { CardTypeEnum } from '@ohos/commonbusiness/src/main/ets/model/CardData';

/* Logger Tags */
const TAG_FW = '[IntentFramework]'
const TAG_PJ = '[IntentPageJumping]'
const TAG_CI = '[CustomIntent]'

export default class InsightIntentExecutorImpl extends InsightIntentExecutor {
  private pageContext: PageContext = AppStorage.get(StorageKey.HOME_PAGE_CONTEXT) as PageContext;
  private page: string = '';
  private intentNameMaps: Map<string, string> = new Map<string, string>();
  private appPathInfo: NavPathStack = this.pageContext.navPathStack;
  public static intentEnumMaps: Map<number, IntentJsonEnumDetail> = new Map<number, IntentJsonEnumDetail>();
  private static instance: InsightIntentExecutorImpl;
  private insightIntentViewModel: InsightIntentViewModel = new InsightIntentViewModel();

  public static getInstance(): InsightIntentExecutorImpl {
    if (!InsightIntentExecutorImpl.instance) {
      InsightIntentExecutorImpl.instance = new InsightIntentExecutorImpl();
    }
    return InsightIntentExecutorImpl.instance;
  }

  onExecuteInUIAbilityForegroundMode(name: string, param: Record<string, Object>, pageLoader: window.WindowStage):
    Promise<insightIntent.ExecuteResult> {
    Logger.info(TAG_FW, `name: ${name} | param: ${JSON.stringify(param)}`);

    if (name === IntentNameEnum.JMP_FN_PAGE || name === IntentNameEnum.JMP_STUDY_PAGE) {
      return this.jumpFunctionPage(param);
    }

    return Promise.resolve({
      code: -1,
      result: {
        message: `Unexpected Entry: unknown intent`
      }
    } as insightIntent.ExecuteResult);
  }

  /** By setting @StorageProp(StorageKey.WANT_PARAMETERS) @Watch('jumpPage') wantParams,
   * which is over-watched by main_page, will trigger page-jumping defined in its VM */
  private jumpToDesignatedPage(pageInfo: IntentJsonEnumDetail): void {
    let wantParameters: WantParams = pageInfo.param as WantParams;
    wantParameters.fromIntent = true;
    if (pageInfo.types === 'ComponentInstruction') {
      wantParameters.moduleType = CardTypeEnum.COMPONENT;
    } else if (pageInfo.types === 'PracticalExample') {
      wantParameters.moduleType = CardTypeEnum.SAMPLE;
    } else if (pageInfo.types === 'BestPracticeArticle') {
      wantParameters.moduleType = CardTypeEnum.ARTICLE;
    }
    Logger.info(TAG_PJ, `params for jumping: ${JSON.stringify(wantParameters)}`);
    AppStorage.setOrCreate<WantParams>(StorageKey.WANT_PARAMETERS, wantParameters);
  }

  /** Try get a detailPageInfo by:
   * 1. it seems it has been already a id -> get pageInfo by id;;
   * 2. do fuzzy match to find one;
   * 3. if not found, return undefined;
   */
  private static tryToGetDetailPageInfo(pageId: string) {
    let detailPageInfo: IntentJsonEnumDetail | undefined = undefined;

    if (!pageId || pageId === INTENT_XIAOYI_DEFAULT_VALUE) {
      Logger.error(TAG_FW, `Xiaoyi didn't extract componentName.`);
      return undefined;
    }

    if (!isNaN(Number(pageId))) {
      Logger.info(TAG_CI, `Got a number, use as pageId directly: ${pageId}`);
      const intentPageList =
        RawfileIO.loadJsonObject('pages_keywords_list.json', ['pageId', 'enum']) as IntentJsonEnumDetail[];
      if (intentPageList.length == 0) {
        Logger.error(TAG_CI,
          `unable to get local page list for intent. Jumping process terminated.`);
        return undefined;
      }
      intentPageList.forEach((intentPage) => {
        if (intentPage.value === pageId) {
          detailPageInfo = intentPage;
        }
      });
    } else {
      Logger.info(TAG_CI, `pageId is NOT a number, use fuzzy match...`);
      detailPageInfo = FuzzyMatch.fuzzyMatchKeywordWithoutWeight(pageId);
    }
    return detailPageInfo;
  }

  jumpFunctionPage(param: Record<string, Object>): Promise<insightIntent.ExecuteResult> {
    let newParam: Record<string, object> = {};
    Object.keys(param).forEach((key: string) => {
      if (!key.startsWith('ohos.aafwk')) {
        newParam[key] = param[key];
      }
    });

    const stringParam: string = JSON.stringify(newParam);
    let stringParamValueOnly = JSON.stringify(Object.values(newParam));
    stringParamValueOnly = stringParamValueOnly.slice(2, stringParamValueOnly.length - 2);
    Logger.info(TAG_CI, `param: ${stringParam}`);
    let pageId: string = (param?.pageId ? param.pageId : stringParamValueOnly) as string;
    Logger.info(TAG_CI, `pageId(original): ${pageId}`);

    let detailPageInfo = InsightIntentExecutorImpl.tryToGetDetailPageInfo(pageId);
    this.page = 'SplashPage';

    return new Promise((resolve, reject) => {
      // distinguish whether it's a cold/hot start
      AppStorage.setOrCreate(StorageKey.HOME_PAGE_INTENTION, 0);
      AppStorage.setOrCreate(StorageKey.HOME_PAGE_INTENTION_CHANGED, 0);
      if (detailPageInfo) {
        this.jumpToDesignatedPage(detailPageInfo);
        resolve({
        code: 0,
        result: {
          message: `Intent execute @jumpFunctionPage accomplished.`
        }
      });
      } else {
        reject({
          code: -1,
          reason: `Intent execute @jumpFunctionPage terminated.`
        })
      }
    });
  }

  public startWithIntent() {
    // Custom Intent
    Logger.info(TAG_FW, `starting with intent...`);
    const appPathInfo = this.appPathInfo.getPathStack();
    appPathInfo.forEach((info) => {
      let reformedInfo: IntentInfo = JSON.parse(JSON.stringify(info)) as IntentInfo;
      if (reformedInfo?.name == '') {
        let componentName: string = reformedInfo.param.componentName;
        this.parseIntentInfo(componentName);
        return;
      }
    });
  }

  public parseIntentInfo(componentName: string = INTENT_XIAOYI_DEFAULT_VALUE, userOriText: string = '') {
    /**
     * Intent Entry of Xiaoyi voice command
     *
     * @param componentName: the componentName that LLM extract from user's sentence.
     * @param userOriText: the whole sentence of user's original input
     */
    Logger.info(TAG_CI, `@parseIntentInfo componentName: ${componentName}`);
    this.setIntentEnumMap();
    if (!componentName || componentName === INTENT_XIAOYI_DEFAULT_VALUE) {
      Logger.error(TAG_FW, `Xiaoyi didn't extract componentName.`);
      AppStorage.setOrCreate(StorageKey.XIAOYI_EXTRACTED_NO_PARAM, true);
    }

    // if no xiaoyi, return idx 0 of intentPagesList -> jump back to main page
    let detailPageInfo: IntentJsonEnumDetail | undefined =
      FuzzyMatch.fuzzyMatchKeywordWithoutWeight(componentName, userOriText, 0);
    if (!detailPageInfo) {
      Logger.error(TAG_CI, `Could not find detailPageInfo...`);
      Toast.showToast($r('app.string.intent_page_not_found'), 8000);
      return;
    }

    Logger.info(TAG_CI, `Initializing function to page jumping, to: ${detailPageInfo.value}. ${detailPageInfo.displayName}`);
    this.page = 'SplashPage';
    this.jumpToDesignatedPage(detailPageInfo);
  }

  setIntentEnumMap(): void {
    /**
     * Load list of all intents from preset-JSON file,
     * if had already loaded, skip,
     * otherwise save into this.intentNameMaps
     */
    if (this.intentNameMaps.size > 0) {
      Logger.info(TAG_CI, `intentNameMaps already loaded.`);
      return;
    }

    const intentEnums: IntentJsonEnumDetail[] = RawfileIO.loadIntentJson();
    if (intentEnums.length == 0) {
      Logger.error(TAG_CI, `received empty list when loading, please check the JSON-files.`);
      return;
    }

    intentEnums.forEach((intent) => {
      const intentDetail: IntentJsonEnumDetail = JSON.parse(JSON.stringify(intent)) as IntentJsonEnumDetail;
      this.intentNameMaps.set(intentDetail.displayName, intentDetail.value.toString());
      // Following process is necessary.
      InsightIntentExecutorImpl.intentEnumMaps.set(parseInt(intentDetail.value), intentDetail);

      intentDetail.keywords.forEach((keyword) => {
        this.intentNameMaps.set(keyword, intentDetail.value.toString());
      });
    });
    Logger.info(TAG_CI, `intentNameMaps updated.`)
  }

  public static onSplashPageAboutToAppear() {
    if (AppStorage.get(StorageKey.HOME_PAGE_INTENTION) === 0) {
      Logger.info(TAG_FW, `Entering with one-step-reach intent.`);
      InsightIntentExecutorImpl.getInstance().startWithIntent();
      return;
    }
  }
}
