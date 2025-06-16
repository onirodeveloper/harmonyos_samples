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
import { ComponentDetailManager } from '../../../viewmodel/ComponentDetailManager';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';

const TAG: string = '[PenKitBuilder]';

@Builder
export function PenKitBuilder($$: DescriptorWrapper) {
  Button($r('app.string.penKit'), { buttonStyle: ButtonStyleMode.NORMAL })
    .fontWeight(FontWeight.Medium)
    .fontSize($r('sys.float.Body_L'))
    .fontColor($r('sys.color.font_emphasize'))
    .onClick(() => {
      if (canIUse('SystemCapability.Stylus.Handwrite')) {
        ComponentDetailManager.getInstance().getDetailViewModel('Penkit')?.jumpToPenKitView();
      } else {
        try {
          promptAction.showToast({ message: $r('app.string.function_handwrite_not_support') });
        } catch (err) {
          const error: BusinessError = err as BusinessError;
          Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
        }
      }
    })
}