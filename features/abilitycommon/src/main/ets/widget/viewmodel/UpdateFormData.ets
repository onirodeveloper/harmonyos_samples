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

import { formBindingData, formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ArticleListItem, Logger } from '@ohos/common';
import {
  AddFormData,
  ArticleServiceCardVM,
  InitEvent,
  RemoveFormData,
  UpdateDataEvent,
} from './ArticleServiceCardVM';

const TAG: string = '[UpdateFormData]';

export class UpdateFormData {
  private static viewModel: ArticleServiceCardVM = ArticleServiceCardVM.getInstance();

  /**
   * Invoke the viewModel to reconstruct the form data by formId.
   *
   * @param formId
   */
  public static update(formId: string): void {
    UpdateFormData.viewModel.sendEvent(new UpdateDataEvent(formId));
    const formData: Record<string, string | ArticleListItem[]> = {
      'cardList': UpdateFormData.viewModel.getState().cardList,
    }
    Logger.info(TAG, `click to check updateForm, formId: ${formId}`);
    const formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    formProvider.updateForm(formId, formInfo).then(() => {
      Logger.info(TAG, 'updateForm success.');
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `updateForm fail, code: ${error?.code}, message: ${error?.message}`);
    })
  }

  /**
   * Init the viewModel, if this cardList length not equal 0, don't need InitEvent.
   *
   * @param formId
   * @returns formBindingData.FormBindingData
   */
  public static init(formId: string): formBindingData.FormBindingData {
    if (UpdateFormData.viewModel.getState().cardList.length === 0) {
      UpdateFormData.viewModel.sendEvent(new InitEvent());
    }
    UpdateFormData.viewModel.sendEvent(new AddFormData(formId, UpdateFormData.viewModel.getState().cardList));
    const cardData: Record<string, string | ArticleListItem[]> = {
      'formId': formId,
      'cardList': UpdateFormData.viewModel.getState().cardList,
    }
    return formBindingData.createFormBindingData(cardData);
  }

  public static removeDataOfFormId(formId: string): void {
    UpdateFormData.viewModel.sendEvent(new RemoveFormData(formId));
  }
}