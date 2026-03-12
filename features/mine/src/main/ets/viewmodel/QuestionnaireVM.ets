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

import { emitter } from '@kit.BasicServicesKit';
import { BaseVM, BaseVMEvent, CommonConstants, SubmitInfoUtil, Toast } from '@ohos/common';
import { QuestionnaireState } from './QuestionnaireState';

const TAG: string = '[QuestionnaireVM]';

export class QuestionnaireVM extends BaseVM<QuestionnaireState> {
  private static instance: QuestionnaireVM;

  public static getInstance(): QuestionnaireVM {
    if (!QuestionnaireVM.instance) {
      QuestionnaireVM.instance = new QuestionnaireVM();
    }
    return QuestionnaireVM.instance;
  }

  private constructor() {
    super(new QuestionnaireState());
  }

  sendEvent(event: BaseVMEvent) {
    if (event instanceof SubmitEvent) {
      this.submitInfo();
    } else if (event instanceof SelectScoreEvent) {
      this.selectScore(event);
    }
  }

  private submitInfo(): void {
    if (this.state.selectedScore > 0) {
      SubmitInfoUtil.submitQuestionnaireInfo(this.state.selectedScore, this.state.questionnaireInput);
      this.resetAllStatus();
      emitter.emit(CommonConstants.BIND_SHEET_CLOSE_EVENT);
    } else {
      Toast.showToast($r('app.string.questionnaire_reason'));
    }
  }

  private selectScore(event: SelectScoreEvent): void {
    this.state.selectedScore = this.state.selectedScore === event.index ? 0 : event.index;
  }

  private resetAllStatus(): void {
    this.state.questionnaireInput = '';
    this.state.selectedScore = 0;
    this.state.editStatus = false;
  }
}

export class SubmitEvent implements BaseVMEvent {
}

export class SelectScoreEvent implements BaseVMEvent {
  public readonly index: number;

  public constructor(index: number) {
    this.index = index;
  }
}