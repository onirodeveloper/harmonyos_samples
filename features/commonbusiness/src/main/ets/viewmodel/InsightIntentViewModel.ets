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
import { StorageKey } from '@ohos/common/src/main/ets/constant/CommonEnums';
import { InsightIntentEventTypeEnum } from '@ohos/common/src/main/ets/constant/IntentEnums';
import { InsightIntentEvent } from '@ohos/common/src/main/ets/model/IntentDataModel';
import { PageEnum } from '@ohos/common/src/main/ets/model/PageEnum';
import { InteractionTypeEnum } from '@ohos/common/src/main/ets/model/TrackModel';
import { PageContext } from '@ohos/common/src/main/ets/routermanager/PageContext';
import Logger from '@ohos/common/src/main/ets/util/Logger';
import { BaseState } from '@ohos/common/src/main/ets/viewmodel/BaseState';
import { BaseVM } from '@ohos/common/src/main/ets/viewmodel/BaseVM';
import { CodeViewParams, ComponentDetailParams, SampleDetailParams } from '../model/RouterParams';

const TAG = '[InsightIntentViewModel]'

export class InsightIntentViewModel extends BaseVM<BaseState> {
  private pageContext: PageContext = AppStorage.get(StorageKey.HOME_PAGE_CONTEXT) as PageContext;

  public constructor() {
    super(new BaseState())
  }

  public sendEvent(eventParam: InsightIntentEvent): void {
    if (eventParam.type === InsightIntentEventTypeEnum.JUMP_TO_MAIN) {
      this.jumpToMainPage();
      return;
    }
    if (!eventParam?.param) {
      Logger.error(TAG, `Missing event parameters!`)
      return;
    }
    if (eventParam.type === InsightIntentEventTypeEnum.JUMP_TO_COMPONENT) {
      this.jumpComponentDetail(eventParam.param.param_1 as number, eventParam.param.param_2 as string);
    } else if (eventParam.type === InsightIntentEventTypeEnum.JUMP_TO_SAMPLE) {
      this.jumpSampleDetail(eventParam.param.param_1 as number, eventParam.param.param_2 as number);
    } else if (eventParam.type === InsightIntentEventTypeEnum.JUMP_TO_PRACTICE) {
      this.jumpToCodePreview(eventParam.param.param_1 as string, eventParam.param.param_2 as string);
    }
  }

  private jumpToMainPage(): void {
    this.pageContext?.replacePage({
      routerName: PageEnum.MAIN_PAGE,
    });
  }

  private jumpComponentDetail(id: number, name: string) {
    const PARAM = {
      id: id,
      title: name,
      interactionType: InteractionTypeEnum.COMPONENT,
    } as ComponentDetailParams;
    this.pageContext.openPage({
      routerName: PageEnum.COMPONENT_DETAIL_VIEW,
      param: PARAM
    })
  }

  private jumpSampleDetail(id: number, index: number): void {
    const PARAM = {
      cardId: id,
      currentIndex: index,
      interactionType: InteractionTypeEnum.SAMPLE,
    } as SampleDetailParams;
    this.pageContext.openPage({
      routerName: PageEnum.SAMPLE_DETAIL_VIEW,
      param: PARAM
    });
  }

  private jumpToCodePreview(code: string, componentName: string): void {
    const PARAM: CodeViewParams = {
      code: code,
      componentName: componentName
    };
    this.pageContext.openPage({
      routerName: PageEnum.CODE_PREVIEW_VIEW,
      param: PARAM
    })
  }
}
