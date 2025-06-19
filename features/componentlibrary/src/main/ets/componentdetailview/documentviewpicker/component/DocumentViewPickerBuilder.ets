/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apach License, Version 2.0 (the "License");
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

import type { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';

const TAG: string = '[DocumentViewPickerComponent]';

@Builder
export function DocumentViewPickerBuilder(_$$: DescriptorWrapper) {
  DocumentViewPickerComponent()
}

@Component
struct DocumentViewPickerComponent {
  @State message: string = '';
  @State title: string = '';

  readFile() {
    const context = getContext(this) as common.Context;
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions();
      const documentPicker = new picker.DocumentViewPicker(context);
      documentPicker.select(documentSelectOptions).then((documentSelectResult: string[]) => {
        if (documentSelectResult.length === 0) {
          return;
        }
        this.message = JSON.stringify(documentSelectResult);
        this.getUIContext().showAlertDialog(
          {
            title: $r('app.string.File_path'),
            message: this.message,
            autoCancel: true,
            alignment: DialogAlignment.Center,
            offset: { dx: 0, dy: DetailPageConstant.ALERT_DIALOG_OFFSET_Y },
            gridCount: 3,
            width: DetailPageConstant.SELECT_RESULT_DIALOG_SIZE,
            height: DetailPageConstant.SELECT_RESULT_DIALOG_SIZE,
            cornerRadius: $r('sys.float.corner_radius_level7'),
            borderWidth: $r('app.float.border_width_normal'),
            borderStyle: BorderStyle.Dashed,
            borderColor: Color.Blue,
            backgroundColor: Color.White,
            textStyle: { wordBreak: WordBreak.BREAK_ALL },
            confirm: {
              value: $r('app.string.dialog_confirm'),
              action: () => {
                Logger.info(TAG, 'Confirm button is clicked.');
              },
            },
            onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
              if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                dismissDialogAction.dismiss();
              }
              if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                dismissDialogAction.dismiss();
              }
            },
          }
        )
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `DocumentViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `DocumentViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  build() {
    Column() {
      Button($r('app.string.select_document'))
        .backgroundColor($r('sys.color.background_secondary'))
        .width($r('app.float.document_select_button_width'))
        .height($r('app.float.button_height_normal'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          this.readFile();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}