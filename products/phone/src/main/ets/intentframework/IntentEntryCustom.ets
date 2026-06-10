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
  'displayName': '详情页',
  'icon': $r('app.media.big_new'),
  'llmDescription': '于打开hmos代码工坊(又称“HarmonyOS代码工坊”、简称为“代码工坊”)中的不同页面。当用户要打开代码工坊查看某个页面，或者提出一个与ArkTS相关的问题希望在代码工坊中找到解答，又或者提出了一个技术需求或者使用场景希望看到相关组件的范例时，调用此意图并提取对应的页面关键词作为参数。当用户提及打开代码工坊时，应该尽量调用本意图，并提取关键词，而非使用对话方式回答。注意用户提出的指令对应的页面可能包括某个具体的样例标题，如“多行文本输入框”，也可能是应用的不同页面，比如“我的”页面，或者“设置页面”。',
  'keywords': ['ArkTS', '详情', '定义', '文档', 'demo', '实现', '样例', '组件', 'HarmonyOS', '鸿蒙系统', '介绍', '实例'],
  'abilityName': 'EntryAbility',
  'executeMode': [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND],
  'parameters': {
    'type': 'object',
    'properties': {
      'componentName': {
        'type': 'string',
        'description': '用户语料中包含目标页面名称，或者ArkTs组件名称、开发实践样例名称或对其功能、内容、适用场景等的描述。如果是页面，可能包含：组件列表、样例页面、我的页面、设置页面等名称；如果是组件、样例名称，则可能包含：文本、按钮、图片、进度条、开关、容器、手写笔、布局、AI能力、弹窗、日历、文件、一多、动效等关键词。'
      }
    }
  },
  'result': {
    'type': 'object',
    'properties': {
      'success': {
        'type': 'boolean',
        'description': '是否成功跳转到详情页'
      },
      'errorMessage': {
        'type': 'string',
        'description': '当跳转失败时返回的错误信息'
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
      resultMessage = '好的， 正在帮你打开HMOS代码工坊';
      Logger.error(TAG, `getStringSync failed, error code: ${err.code}, message: ${err.message}`);
    }
    return resultMessage;
  }
}

