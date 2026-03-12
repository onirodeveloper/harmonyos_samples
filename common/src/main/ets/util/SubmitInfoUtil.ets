/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import Toast from '../component/Toast';
import { FeedbackInitParams, FeedbackData, FeedbackType } from '../model/FeedbackData';
import Logger from './Logger';

const TAG = '[SubmitInfoUtil]';

export class SubmitInfoUtil {
  public static submitFeedbackInfo(initParams: FeedbackInitParams, feedbackData: FeedbackData,
    listSelected: boolean[]): void {
    const reasonInfo: string = SubmitInfoUtil.getFeedbackReasonInfo(feedbackData, listSelected);
    Logger.info(TAG,
      `Title: ${initParams.domainTitle}, FeedbackType: ${feedbackData.feedbackTypeStatus},
      Reason: ${reasonInfo}, Descrption: ${feedbackData.feedbackInput}`);
    Toast.showToast($r('app.string.submitted'));
  }

  public static submitQuestionnaireInfo(score: number, questionnaireInput: string): void {
    Logger.info(TAG, `Score: ${score}, Descrption: ${questionnaireInput}`);
    Toast.showToast($r('app.string.submitted'));
  }

  public static getFeedbackReasonInfo(feedbackData: FeedbackData, listSelected: boolean[]): string {
    return (feedbackData.feedbackTypeStatus === FeedbackType.LIKE) ?
      SubmitInfoUtil.filterReasonInfo(feedbackData.likeReasonList, listSelected) :
      SubmitInfoUtil.filterReasonInfo(feedbackData.dislikeReasonList, listSelected);
  }

  public static filterReasonInfo(selectionList: string[], listSelected: boolean[]): string {
    if (selectionList.length !== listSelected.length) {
      return '';
    }
    return listSelected.map((isSelected, index) => isSelected ? selectionList[index] : undefined)
      .filter(Boolean)
      .join(',');
  }
}