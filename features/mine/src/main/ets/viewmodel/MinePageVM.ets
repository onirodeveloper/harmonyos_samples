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

import { BaseVM, BaseVMEvent } from '@ohos/common';
import { MinePageState } from './MinePageState';

export class MinePageVM extends BaseVM<MinePageState> {
  private static instance: MinePageVM;

  public static getInstance() {
    if (!MinePageVM.instance) {
      MinePageVM.instance = new MinePageVM();
    }
    return MinePageVM.instance;
  }

  private constructor() {
    super(new MinePageState());
  }

  public sendEvent(event: BaseVMEvent): void {
    if (event instanceof AboutBindSheetEvent) {
      this.state.aboutViewShow = event.dataValue;
    } else if (event instanceof FeedbackBindSheetEvent) {
      this.state.feedbackViewShow = event.dataValue;
    }
  }
}

export class AboutBindSheetEvent implements BaseVMEvent {
  readonly dataValue: boolean;

  constructor(dataValue: boolean) {
    this.dataValue = dataValue;
  }
}

export class FeedbackBindSheetEvent implements BaseVMEvent {
  readonly dataValue: boolean;

  constructor(dataValue: boolean) {
    this.dataValue = dataValue;
  }
}