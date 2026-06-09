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

import { Want } from '@kit.AbilityKit';
import { FormExtensionAbility } from '@kit.FormKit';
import { FormAbilityHelper } from '@ohos/abilitycommon';

const TAG: string = '[PcFormAbility]';

export default class PcFormAbility extends FormExtensionAbility {
  private baseFormAbilityHelper: FormAbilityHelper = new FormAbilityHelper();

  onAddForm(want: Want) {
    return this.baseFormAbilityHelper.doOnAddForm(want);
  }

  onCastToNormalForm(formId: string) {
    this.baseFormAbilityHelper.doOnCastToNormalForm(formId);
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    this.baseFormAbilityHelper.doOnUpdateForm(formId);
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
    this.baseFormAbilityHelper.doOnFormEvent(formId, message);
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    this.baseFormAbilityHelper.doOnRemoveForm(formId);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return this.baseFormAbilityHelper.doOnAcquireFormState(want);
  }
};