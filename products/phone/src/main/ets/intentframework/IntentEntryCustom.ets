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

import { JSON } from '@kit.ArkTS';
import { insightIntent, InsightIntentEntry, InsightIntentEntryExecutor } from '@kit.AbilityKit';
import { INTENT_XIAOYI_DEFAULT_VALUE } from '@ohos/common';
import { StorageKey } from '@ohos/common/src/main/ets/constant/CommonEnums';
import Logger from '@ohos/common/src/main/ets/util/Logger';
import { IntentParam } from '@ohos/common/src/main/ets/model/IntentDataModel';
import InsightIntentExecutorImpl from './InsightIntentExecutorImpl';

const TAG = '[CustomIntent]';

@InsightIntentEntry({
  'intentName': 'OpenExampleDetail',
  'domain': 'ToolsDomain',
  'intentVersion': '1.0.2',
  'displayName': 'Details Page',
  'icon': $r('app.media.big_new'),
  'llmDescription': 'Open different pages in the HMOS Code Workshop, also known as HarmonyOS Code Workshop or Code Workshop. Use this intent when the user wants to open a page, find an answer to an ArkTS question, or view a component example for a technical requirement or usage scenario. Extract page keywords from the request. When the user mentions opening Code Workshop, prefer this intent and extract keywords instead of answering conversationally. The requested page may be a specific sample, such as a multiline text input, or an app page such as My Page or Settings.',
  'keywords': ['ArkTS', 'details', 'definition', 'documentation', 'demo', 'implementation', 'sample', 'component', 'HarmonyOS', 'introduction', 'example'],
  'abilityName': 'EntryAbility',
  'executeMode': [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND],
  'parameters': {
    'type': 'object',
    'properties': {
      'componentName': {
        'type': 'string',
        'description': 'The user text contains a target page name, an ArkTS component name, a development practice sample name, or a description of its function, content, or applicable scenario. For pages, it may include component list, sample page, My Page, or Settings. For components and samples, keywords may include text, button, image, progress bar, switch, container, stylus, layout, AI capability, dialog, calendar, file, adaptive layout, or animation.'
      }
    }
  },
  'result': {
    'type': 'object',
    'properties': {
      'success': {
        'type': 'boolean',
        'description': 'Whether navigation to the details page succeeded'
      },
      'errorMessage': {
        'type': 'string',
        'description': 'The error message returned when navigation fails'
      }
    }
  }
})
export default class IntentEntryCustom extends InsightIntentEntryExecutor<string> {
  private static instance: IntentEntryCustom;

  public static getInstance(): IntentEntryCustom {
    if (!IntentEntryCustom.instance) {
      IntentEntryCustom.instance = new IntentEntryCustom();
    }
    return IntentEntryCustom.instance;
  }

  onExecute(): Promise<insightIntent.IntentResult<string>> {
    Logger.info(0x0000, TAG, 'executeMode %{public}s', JSON.stringify(this.executeMode));

    const info = JSON.parse(JSON.stringify(this)) as IntentParam;
    Logger.info(TAG, `@IntentEntryCustom: info: ${JSON.stringify(info)}`);

    const componentName: string = info?.componentName ? info.componentName : INTENT_XIAOYI_DEFAULT_VALUE;
    const userOriText: string = info?.systemOriText ? info.systemOriText : '';

    if (componentName === INTENT_XIAOYI_DEFAULT_VALUE) {
      Logger.error(TAG, `componentName was not extracted by Xiaoyi correctly, and has been set to ${INTENT_XIAOYI_DEFAULT_VALUE}`);
    } else {
      Logger.info(TAG, `componentName: ${componentName}`);
    }
    if (userOriText) {
      Logger.info(TAG, `Xiaoyi >> ${userOriText}`);
    }

    AppStorage.setOrCreate(StorageKey.HOME_PAGE_INTENTION_CUSTOM, 0); // help distinguish if it's a cold-start.


    let resultMessage: string = this.getStringResource('app.string.intent_execute_result');

    let result: insightIntent.IntentResult<string> = {
      code: 0,
      result: resultMessage
    }

    return new Promise((resolve, reject) => {
      setTimeout(() => {
        try {
          InsightIntentExecutorImpl.getInstance().parseIntentInfo(componentName, userOriText);
          Logger.info(TAG, `returns ${JSON.stringify(result)}`);
        } catch (err) {
          Logger.error(TAG, `Error happend when parseing Intent...`)
          result.code = -1;
          result.result = 'Failed.';
        }
        resolve(result);
      }, 600)
    });
  }

  private getStringResource(resource: string) {
    let resultMessage: string = '';
    try {
      resultMessage = getContext(this).resourceManager.getStringSync($r(resource));
    } catch (err) {
      resultMessage = 'Opening HMOS Code Workshop for you.';
      Logger.error(TAG, `getStringSync failed, error code: ${err.code}, message: ${err.message}`);
    }
    return resultMessage;
  }
}

