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
import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { UpdateFormData } from '@ohos/abilitycommon/src/main/ets/widget/viewmodel/UpdateFormData';
import { Logger, FormInfo, FormRdbHelper } from '@ohos/common';
import { LIVE_CARD_RATIO } from '@ohos/widgetcommon';

const TAG: string = '[PhoneFormAbility]';

export default class PhoneFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    if (!want || !want.parameters) {
      Logger.error(TAG, 'FormAbility onAddForm want or want.parameters is undefined.');
      return formBindingData.createFormBindingData('');
    }
    const formName: string = want.parameters?.[formInfo.FormParam.NAME_KEY] as string;
    const formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    const formDimension = want.parameters?.[formInfo.FormParam.DIMENSION_KEY] as string;
    if (formName === 'ArticleServiceCard' && formId) {
      return UpdateFormData.init(formId);
    } else if (formName === 'hmos_3d_live_widget' && formId) {
      let formInfo = new FormInfo(formId, formName, formDimension);
      Logger.info(TAG, `onAddForm formInfo: ${JSON.stringify(formInfo)}`);
      FormRdbHelper.getInstance(this.context).insertForm(formInfo);

      this.trigger3DLiveRequest(formId);
    }
    // Triggered when creating a new widget, returns widget's data for binding.
    return formBindingData.createFormBindingData('');
  }

  onCastToNormalForm(_formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    UpdateFormData.update(formId);

    FormRdbHelper.getInstance(this.context)
      .queryFormById(formId)
      .then((formInfo) => {
        Logger.info(TAG, `onUpdateForm`);
      })
    this.trigger3DLiveRequest(formId);
  }

  onFormEvent(_formId: string, _message: string) {
    // Called when a specified message event defined by the form provider is triggered.
    let shortMessage: string = JSON.parse(_message)['message'];
    Logger.info(TAG, `onFormEvent`);

    // When user click the card and triggered play of card's animation
    if (shortMessage === 'requestOverFlow') {
      this.trigger3DLiveRequest(_formId);
    }
    try {
      // set a update for card after 5min.
      formProvider.setFormNextRefreshTime(_formId, 6, (err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to setFormNextRefreshTime. Code: ${err.code}, message: ${err.message}`);
          return ;
        } else {
          Logger.info(TAG, `Succeeded in setFormNextRefreshTiming.`);
        }
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to setFormNextRefreshTime. Code: ${err.code}, message: ${err.message}`);
    }
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    Logger.info(TAG, `onRemoveForm`);
    UpdateFormData.removeDataOfFormId(formId);
  }

  onAcquireFormState(_want: Want) {
    return formInfo.FormState.READY;
  }

  onFormLocationChanged(formId: string, newFormLocation: formInfo.FormLocation): void {
    this.trigger3DLiveRequest(formId);
  }

  private trigger3DLiveRequest(formId: string) {
    formProvider.getFormRect(formId).then((data: formInfo.Rect) => {
      // LIVE_CARD_RATIO: card becomes x time bigger.
      let cardWidth = data.width * LIVE_CARD_RATIO;
      let cardHeight = data.height * LIVE_CARD_RATIO;
      let leftOffset = (data.width - cardWidth) / 2;
      let topOffset = (data.height - cardHeight) / 2;
      formProvider.requestOverflow(formId, {
        area: {
          left: leftOffset,
          top: topOffset,
          width: cardWidth,
          height: cardHeight
        },
        duration: 3500
      }).then(() => {
        Logger.info(TAG, 'requestOverflow result succeed');
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `requestOverflow catch error, code: ${error.code}, message: ${error.message}`)
      })
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `getFormRect catch error, code: ${error.code}, message: ${error.message}`)
    })
    return;
  }
};