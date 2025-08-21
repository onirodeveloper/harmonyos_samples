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


import { StorageKey, Toast } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { ActionSheetDescriptor } from '../viewmodel/ActionSheetDescriptor';

@Builder
export function ActionSheetBuilder($$: DescriptorWrapper) {
  Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
    Button($r('app.string.action_sheet_tip'), { buttonStyle: ButtonStyleMode.NORMAL })
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_emphasize'))
      .onClick(() => {
        const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
        uiContext.showActionSheet({
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
              Toast.showLongToast($r('app.string.confirm_click'));
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