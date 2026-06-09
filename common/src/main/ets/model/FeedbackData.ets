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

export enum FeedbackDomain {
  COMPONENT = 1,
  SAMPLE = 2,
}

export enum FeedbackType {
  LIKE = 1,
  DISLIKE = 2,
  NONE = 3,
}

@Observed
export class FeedbackInitParams {
  public domain: FeedbackDomain = FeedbackDomain.SAMPLE;
  public domainId: number = 0;
  public domainTitle: string = '';
  public likeReasonsResource: Resource = $r('app.string.feedback_reason');
  public dislikeReasonsResource: Resource = $r('app.string.feedback_reason');
}

@Observed
export class FeedbackData {
  public feedbackTypeStatus: FeedbackType = FeedbackType.NONE;
  public editStatus: boolean = false;
  public feedbackInput: string = '';
  public listSelected: boolean = false;
  public feedbackHeight: number = 0;
  public canSubmit: boolean = false;
  public likeReasonList: string[] = [];
  public dislikeReasonList: string[] = [];
}