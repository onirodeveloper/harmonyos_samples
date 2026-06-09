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
/**
 *
 */
import { util } from '@kit.ArkTS';
import Logger from './Logger';
import { StorageKey } from '../constant/CommonEnums';
import { INTENT_XIAOYI_DEFAULT_VALUE } from '../constant/IntentConstants';
import { IntentJsonEnumDetail } from '../model/IntentDataModel';
import { FuzzyMatchResult } from '../model/FuzzyMatchDataModel';
import { WHEN_LENGTH_SHORTER_THAN_FOURTEEN } from './FuzzyMatchConstants';

/* Tags */
const TAG_FM = '[FuzzyMatch]';
const TAG_IO = '[FileIO]';

export class FuzzyMatch {
  /**
   * @param stringParam
   * @param userOriText
   * @param matchThreshold
   * @returns
   */
  private static fuzzyMatchKeywordWithWeight(stringParam: string, userOriText: string = ''): string {
    Logger.debug(``)
    return ''
  }

  /**
   * match intents one by one, returns <string>id of best matched page.
   * @param stringParam param got from Xiaoyi
   * @param userOriText the whole sentence that user inputted to Xiaoyi
   * @param matchThreshold
   * @returns
   */
  public static fuzzyMatchKeywordWithoutWeight(stringParam: string,
    userOriText: string = '', defaultIdx?: number): IntentJsonEnumDetail | undefined {
    Logger.info(TAG_FM, `@fuzzyMatchKeywordWithoutWeight stringParam: ${stringParam}`);

    const intentPageList =
      RawfileIO.loadJsonObject('pages_keywords_list.json', ['pageId', 'enum']) as IntentJsonEnumDetail[];
    if (intentPageList.length == 0) {
      Logger.error(TAG_FM,
        `@fuzzyMatchKeywordWithoutWeight: unable to get local page list for intent. Jumping process terminated.`);
      return undefined;
    }
    if (!stringParam || stringParam === INTENT_XIAOYI_DEFAULT_VALUE) {
      Logger.error(TAG_FM, `@fuzzyMatchKeywordWithoutWeight: Xiaoyi got no valid stringParam.`);
      if (defaultIdx === undefined || (defaultIdx < 0 || defaultIdx >= intentPageList.length)) {
        return undefined;
      } else {
        return intentPageList[defaultIdx];
      }

    }

    /** round 1 of 3 matching - match page keywords with component description extracted by Xiaoyi from users' input */
    const matchResult1st: FuzzyMatchResult = FuzzyMatch.fuzzyMatchStringParam(stringParam, intentPageList);
    const bestMatch1st = matchResult1st.bestMatch;

    if (bestMatch1st.length === 0) {
      Logger.error(TAG_FM, `@fuzzyMatchWithoutWeight unable to match any intent page...`)
      return undefined;
    }

    if (bestMatch1st.length === 1) { // find only one best-match, stop here and return
      const pageId: string = bestMatch1st[0].value.toString();
      Logger.info(TAG_FM, `@fuzzyMatchWithoutWeight: best matched: ${pageId} | Score: ${matchResult1st.bestMatchScore}
      fuzzy matched from intent: ${JSON.stringify(bestMatch1st[0])}`);
      return bestMatch1st[0];
    }

    if (!userOriText) {
      Logger.info(TAG_FM, `User's original input was not given, further match methods are skipped.`)
      const pageId: string = bestMatch1st[0].value.toString();
      return bestMatch1st[0];
    }

    /** round 2 of 3 marching - match page type with users' original prompt, if given */
    const matchResult2nd: FuzzyMatchResult = FuzzyMatch.fuzzyMatchPageType(bestMatch1st, userOriText);
    const bestMatch2nd: IntentJsonEnumDetail[] = matchResult2nd.bestMatch;

    if (bestMatch2nd.length === 1) {
      const pageId: string = bestMatch2nd[0].value.toString();
      Logger.info(TAG_FM,
        `@fuzzyMatchWithoutWeight: best matched after round-2: ${pageId} | Score: ${matchResult2nd.bestMatchScore}\n` +
          `fuzzy matched from intent: ${JSON.stringify(bestMatch2nd[0])}`);
      return bestMatch2nd[0];
    } else if (bestMatch2nd.length === 0) {
      const pageId: string = bestMatch1st[0].value.toString();
      Logger.info(TAG_FM, `@fuzzyMatchWithoutWeight: best matched: ${pageId} | Score: ${matchResult2nd.bestMatchScore}
      fuzzy matched from intent: ${JSON.stringify(bestMatch1st[0])}`);
      return bestMatch1st[0];
    }

    /** round 3 of 3 matching - match pages' display-name with users' original prompt, if given */
    let bestMatch3rd: IntentJsonEnumDetail[] = [];
    let bestMatchScore3rd: number = 0;
    Logger.info(TAG_FM, `Still got ${bestMatch2nd.length} intents. Proceeding final round.`);
    bestMatch2nd.forEach((intentPage) => {
      let matchedScore: number = FuzzyMatch.getStringSimilarity(userOriText.toLowerCase(), intentPage.displayName, 0,
        FuzzyMatch.LongestCommonSubString);
      Logger.debug(TAG_FM, `Candidate Page: ${intentPage.displayName} - NameScore: ${matchedScore}`);
      if (matchedScore > bestMatchScore3rd) {
        bestMatch3rd = [intentPage];
        bestMatchScore3rd = matchedScore;
      }
    });
    if (bestMatchScore3rd > 0) {
      // this is the final approach, can't help if there are more than one result;
      const pageId: string = bestMatch3rd[0].value.toString();
      Logger.info(TAG_FM, `@fuzzyMatchWithoutWeight: best matched after round-3: \n` +
        `${pageId} | Score: ${bestMatchScore3rd} \n` +
        `fuzzy matched from intent: ${JSON.stringify(bestMatch3rd[0])}`);
      return bestMatch3rd[0];
    } else {
      const pageId: string = bestMatch2nd[0].value.toString();
      Logger.info(TAG_FM, `@fuzzyMatchWithoutWeight: best matched after round-2:\n` +
        `${pageId} | Score: ${matchResult2nd.bestMatchScore}\n` +
        `fuzzy matched from intent: ${JSON.stringify(bestMatch2nd[0])}`);
      if (bestMatch2nd.length) {
        return bestMatch2nd[0];
      } else {
        return bestMatch1st[0];
      }
    }
  }

  /** round 1 of 3 matching - match page keywords with component description extracted by Xiaoyi from users' input */
  private static fuzzyMatchStringParam(stringParam: string, intentPageList: IntentJsonEnumDetail[]): FuzzyMatchResult {
    let bestMatch1st: IntentJsonEnumDetail[] = [];
    let bestMatchScore1st: number = 0;
    intentPageList.forEach((intentPage: IntentJsonEnumDetail) => {
      if (intentPage?.state && intentPage.state === 0) {
        return;
      }

      let matchedScore: number = 0;

      const allKeywords: string[] = [];
      allKeywords.push(intentPage.displayName);
      allKeywords.push(...intentPage.keywords);
      if (intentPage.displayDescription) {
        allKeywords.push(intentPage.displayDescription);
      }

      allKeywords.forEach((keyword: string) => {
        matchedScore += FuzzyMatch.getStringSimilarity(stringParam.toLowerCase(), keyword.toLowerCase(), 0,
          FuzzyMatch.LongestCommonSubSequence);
      });
      if (matchedScore > bestMatchScore1st) {
        bestMatchScore1st = matchedScore;
        bestMatch1st = [intentPage];
      } else if (matchedScore && matchedScore == bestMatchScore1st) {
        bestMatch1st.push(intentPage);
      }
    });
    return { bestMatch: bestMatch1st, bestMatchScore: bestMatchScore1st };
  }

  /** round 2 of 3 marching - match page type with users' original prompt, if given */
  private static fuzzyMatchPageType(lastRoundResult: IntentJsonEnumDetail[], userOriText: string): FuzzyMatchResult {
    Logger.debug(TAG_FM, `${lastRoundResult} intentPages matched. Proceeding 2nd round matching.`);
    const pagesTypeList = RawfileIO.loadJsonObject('insight_intent_page_type.json', ['pageType']);

    if (!pagesTypeList) {
      Logger.error(TAG_FM,
        `@fuzzyMatchPageType: unable to get local page type list for intent. Matching process terminated.`);
      return { bestMatch: [], bestMatchScore: 0 };
    }

    let bestMatch2nd: IntentJsonEnumDetail[] = [];
    let bestMatchScore2nd: number = 0;

    lastRoundResult.forEach((intentPage) => {
      let matchedScore: number = 0;
      const keywordsOfType: string[] = pagesTypeList[intentPage.types];
      if (!Array.isArray(keywordsOfType) || keywordsOfType.length == 0) {
        Logger.error(TAG_FM, `@fuzzyMatchPageType: Invalid page types: ${intentPage.types}.`);
        return;
      }
      keywordsOfType.forEach((keyword) => {
        matchedScore += FuzzyMatch.getStringSimilarity(userOriText.toLowerCase(), keyword.toLowerCase(), 0,
          FuzzyMatch.LongestCommonSubString);
      });
      Logger.debug(TAG_FM, `Candidate Page: ${intentPage.displayName} - TypeScore: ${matchedScore}`);
      if (matchedScore > bestMatchScore2nd) {
        bestMatchScore2nd = matchedScore;
        bestMatch2nd = [intentPage];
      } else if (matchedScore && matchedScore == bestMatchScore2nd) {
        bestMatch2nd.push(intentPage);
      }
    });
    return { bestMatch: bestMatch2nd, bestMatchScore: bestMatchScore2nd };
  }

  /**
   * returns similarity of strA and strB in percentage number (0~100) when it reaches threshold,
   * or returns 0 when under threshold.
   * @param matchThreshold
   * @param matchMethod
   * @returns
   */
  public static getStringSimilarity(strA: string, strB: string, matchRateThreshold: number = 0,
    matchMethod: Function = ((strA: string, strB: string) => {
    })): number {

    let matchResult: number = 0;
    let matchSimRate: number = 0;

    const shortLen = Math.min(strA.length, strB.length);

    if (matchRateThreshold == 0) {
      matchRateThreshold = shortLen < 15 ? Math.floor(100 * WHEN_LENGTH_SHORTER_THAN_FOURTEEN[shortLen]) / shortLen : 46
    }
    matchResult = matchMethod(strA, strB);
    matchSimRate = Math.floor(100 * matchResult / shortLen);

    return (matchSimRate >= matchRateThreshold) ? matchResult : 0;
  }

  /**
   * Find the longest common sub-string (not sub-sequence!)
   * @returns <Number>
   */
  public static LongestCommonSubString(strA: string, strB: string): number {
    const m: number = strA.length;
    const n: number = strB.length;
    if (m == 0 || n == 0) {
      return 0;
    } else if (strA == strB) {
      // Case insensitive situation, therefore, == sign can be used.
      return strA.length;
    }
    ;

    const shorter = m <= n ? strA : strB;
    const longer = m <= n ? strB : strA;
    const shorterLen = shorter.length;
    const longerLen = longer.length;

    // DP-Algorithm
    let prevRow: number[] = new Array(shorterLen + 1).fill(0);
    let currRow: number[] = new Array(shorterLen + 1).fill(0);
    let maxLength = 0;

    for (let i = 1; i <= longerLen; i++) {
      for (let j = 1; j <= shorterLen; j++) {
        if (longer[i - 1] === shorter[j - 1]) {
          currRow[j] = prevRow[j-1] + 1;

          if (currRow[j] > maxLength) {
            maxLength = currRow[j];
          }
        } else {
          currRow[j] = 0;
        }
      }
      const exchangeLine = prevRow;
      prevRow = currRow;
      currRow = exchangeLine;

      currRow[0] = 0;
    }
    return maxLength;
  }

  public static LongestCommonSubSequence(strA: string, strB: string): number {
    const m = strA.length;
    const n = strB.length;

    if (m == 0 || n == 0) {
      return 0;
    } else if (strA == strB) {
      // Case insensitive situation, therefore, == sign can be used.
      return Math.min(m, n);
    }

    const shorter = m <= n ? strA : strB;
    const longer = m <= n ? strB : strA;
    const shorterLen = shorter.length;
    const longerLen = longer.length;

    // DP-Algorithm
    let prevRow: number[] = new Array(shorterLen + 1).fill(0);
    let currRow: number[] = new Array(shorterLen + 1).fill(0);

    for (let i = 1; i <= longerLen; i++) {
      for (let j = 1; j <= shorterLen; j++) {
        if (longer[i - 1] === shorter[j - 1]) {
          currRow[j] = prevRow[j - 1] + 1;
        } else {
          currRow[j] = Math.max(prevRow[j], currRow[j - 1]);
        }
      }

      prevRow = [...currRow];
    }
    return prevRow[shorterLen];
  }

  public static LevenshteinDistance(strA: string, strB: string): number {
    const m = strA.length;
    const n = strB.length;

    if (m == 0 || n == 0) {
      return Math.max(m, n);
    } else if (strA == strB) {
      // Case insensitive situation, therefore, == sign can be used.
      return 0;
    }

    const shorter = m <= n ? strA : strB;
    const longer = m <= n ? strB : strA;
    const shorterLen = shorter.length;
    const longerLen = longer.length;

    // DP-Algorithm
    let prevRow: number[] = new Array(shorterLen + 1).fill(0);
    let currRow: number[] = new Array(shorterLen + 1).fill(0);

    for (let i = 1; i <= longerLen; i++) {
      for (let j = 1; j <= shorterLen; j++) {
        const cost = strA[i - 1] == strB[j - 1] ? 0 : 1;
        currRow[j] = Math.min(
          prevRow[j] + 1, // Delete
          currRow[j - 1] + 1, // Add
          prevRow[j - 1] + cost // Replace
        );
      }
      prevRow = [...currRow];
    }
    return prevRow[shorterLen];
  }
}

export class RawfileIO {
  /**
   * load the categories of all pages, including index pages, components, practical examples and articles,
   * corresponding to the intent, from the designated file.
   * @param filename
   * @param props
   * @returns
   */
  public static loadJsonObject(filename: string = '', props: Array<string | number> = []): Array<object> {
    Logger.debug(TAG_IO, `@loadJsonObject: loading file: ${filename}`);
    try {
      let context: Context | undefined = AppStorage.get(StorageKey.CONTEXT_ENTRY);
      if (!context) {
        Logger.error(TAG_IO, `@loadJsonObject: unabled to get context from StroageKey.`);
        return [];
      } else {
        Logger.debug(TAG_IO, `@loadJsonObject: context: ${JSON.stringify(context)}`);
      }

      const fileContent: Uint8Array = context.resourceManager.getRawFileContentSync(filename);
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const decodedFileContent: string = textDecoder.decodeToString(fileContent, { stream: false });
      let ret: object = JSON.parse(decodedFileContent);
      props.forEach((propertyOrElement) => {
        if (ret) {
          ret = ret[propertyOrElement];
        } else {
          throw new TypeError(`${TAG_IO}: Cannot read property/element. (Reading '${propertyOrElement}')`);
        }
      });

      if (ret) {
        Logger.info(TAG_IO, `File parsed. Number of returned contents: ${Object.keys(ret).length}`);
        return ret as Array<object>;
      } else {
        Logger.error(TAG_IO, `Load and parsing failed.`);
        return [];
      }
    } catch (error) {
      const code = (error as BusinessError).code;
      const message = (error as BusinessError).message;
      Logger.error(TAG_IO,
        `Error happend during loading and parsing file content.\nError code: ${code}, message: ${message}`);

      return [];
    }
  }

  public static loadIntentJson(filename: string = 'insight_intent_local.json'): IntentJsonEnumDetail[] {
    const intentEnum: object =
      RawfileIO.loadJsonObject(filename, ['insightIntents', 0, 'inputParams', 0, 'properties', 'pageId', 'enum']);
    return intentEnum as IntentJsonEnumDetail[];
  }
}
