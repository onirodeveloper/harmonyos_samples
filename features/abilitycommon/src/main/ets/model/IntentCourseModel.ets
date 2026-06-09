import { util } from '@kit.ArkTS';
import { insightIntent } from '@kit.IntentsKit';
import { IntentJsonEnumDetail, RawfileIO } from '@ohos/common';
import { INTENT_NAME, INTENT_VERSION } from '@ohos/common';

export default class IntentCourseModel {

  static localSearchAll(): insightIntent.InsightIntent[] {
    const intentEnums = RawfileIO.loadIntentJson();
    const intentSearchAll = intentEnums.map(turnIntentInfoIntoArrayElement);
    return intentSearchAll;
  }
}

function localSearchSingle(entityId: string, entityDisplayName: string, entityDescription: string,
  entityLogoURL: string, keywords: string[]): insightIntent.InsightIntent {
  /** Local Search - HMOS World content search */
  return {
    'intentName': INTENT_NAME,
    'intentVersion': INTENT_VERSION,
    'identifier': util.generateRandomUUID(true).toString(),
    'intentActionInfo': {
      'actionMode': 'EXECUTED',
      'executedTimeSlots': {
        'executedStartTime': new Date().getTime(),
        'executedEndTime': new Date().getTime(),
      },
      'currentPercentage': 50,
    },
    'intentEntityInfo': {
      'entityName': 'Course',
      'entityId': entityId,
      'entityDisplayName': entityDisplayName,
      'entityDescription': entityDescription,
      'entityLogoURL': entityLogoURL,
      'courseName': '组件或样例详情',
      'entityGroupId': '2025121',
      'keywords': keywords,
    }
  };
}

function turnIntentInfoIntoArrayElement(intent: IntentJsonEnumDetail) {
  const ELEMENT =
    localSearchSingle(intent.value, intent.displayName, intent.displayDescription, intent.icon, intent.keywords);
  return ELEMENT;
}