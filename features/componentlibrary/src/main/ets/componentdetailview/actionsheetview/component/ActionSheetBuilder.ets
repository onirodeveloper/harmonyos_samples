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

import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { ActionSheetDescriptor } from '../viewmodel/ActionSheetDescriptor';

const TAG: string = '[ActionSheetBuilder]';

@Builder
export function ActionSheetBuilder($$: DescriptorWrapper) {
  Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
    Button($r('app.string.action_sheet_tip'), { buttonStyle: ButtonStyleMode.NORMAL })
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_emphasize'))
      .onClick(() => {
        ActionSheet.show({
          title: $r('app.string.title'),
          subtitle: $r('app.string.subtitle'),
          message: $r('app.string.content'),
          autoCancel: ($$.descriptor as ActionSheetDescriptor).autoCancel,
          transition: TransitionEffect.asymmetric(
            ($$.descriptor as ActionSheetDescriptor).transitionAppear,
            ($$.descriptor as ActionSheetDescriptor).transitionDisappear
          ),
          confirm: {
            defaultFocus: true,
            value: $r('app.string.dialog_confirm'),
            action: () => {
              try {
                promptAction.showToast({
                  message: $r('app.string.confirm_click'),
                  duration: DetailPageConstant.LONG_DURATION,
                });
              } catch (err) {
                const error: BusinessError = err as BusinessError;
                Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
              }
            },
          },
          alignment: DialogAlignment.Center,
          offset: { dx: 0, dy: DetailPageConstant.ACTION_SHEET_OFFSET_Y },
          sheets: ($$.descriptor as ActionSheetDescriptor).sheetInfo,
        });
      })
  }
  .width('100%')
  .height('100%')
}