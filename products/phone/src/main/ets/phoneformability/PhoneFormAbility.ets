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

import type { Want } from '@kit.AbilityKit';
import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Logger } from '@ohos/common';
import { UpdateFormData } from '../util/UpdateFormData';

const TAG: string = '[PhoneFormAbility]';

export default class PhoneFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    if (!want || !want.parameters) {
      Logger.error(TAG, 'FormAbility onAddForm want or want.parameters is undefined.');
      return formBindingData.createFormBindingData('');
    }
    const formName: string = want.parameters?.[formInfo.FormParam.NAME_KEY] as string;
    const formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string;
    if (formName === 'ArticleServiceCard') {
      return UpdateFormData.init(formId);
    }
    return formBindingData.createFormBindingData('');
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    UpdateFormData.update(formId);
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    UpdateFormData.removeDataOfFormId(formId);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};