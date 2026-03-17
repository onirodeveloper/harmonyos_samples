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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalInfoModel, Logger, StorageKey } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { TextAreaDescriptor } from '../viewmodel/TextAreaDescriptor';
import { TextAreaAttributeModifier } from '../viewmodel/TextAreaAttributeModifier';

const TAG: string = '[TextAreaBuilder]';

@Builder
export function TextAreaBuilder($$: DescriptorWrapper) {
  TextAreaComponent({ textAreaDescriptor: $$.descriptor as TextAreaDescriptor })
}

@Component
struct TextAreaComponent {
  @Prop textAreaDescriptor: TextAreaDescriptor;
  @State textStr: ResourceStr = $r('app.string.textarea_text');
  // Height of the component preview area.
  @State textAreaInputHeight: number = 0;
  @State contentOffset: number = 0;
  private uiContext: UIContext = this.getUIContext();
  private context: Context = this.uiContext.getHostContext() as Context;
  private currentWindow?: window.Window;

  aboutToAppear(): void {
    try {
      if (!this.context) {
        Logger.error(TAG, `GetLastWindow failed. Cause context is undefined.`);
        return;
      }
      window.getLastWindow(this.context).then(currentWindow => {
        // Monitor the appearance and disappearance of the soft keyboard.
        this.currentWindow = currentWindow;
        currentWindow.on('avoidAreaChange', this.handleKeyboard);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `getLastWindow failed, cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `CurrentWindow invoke error, the code is ${error.code}, the message is ${error.message}`);
    }
  }

  private handleKeyboard = async (areaOption: window.AvoidAreaOptions) => {
    if (areaOption.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
      return;
    }
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
    const keyboardHeight: number = this.uiContext.px2vp(areaOption.area.bottomRect.height);
    /* When the size of the component preview area exceeds half the screen, the keyboard
     will cover the preview area. At this time, the component needs to move up when the keyboard appears.
     */
    if (keyboardHeight > 0 && this.textAreaInputHeight / globalInfoModel.deviceHeight > 0.5) {
      this.contentOffset = keyboardHeight / 2;
    } else {
      this.contentOffset = 0;
    }
  }

  aboutToDisappear(): void {
    try {
      this.currentWindow?.off('avoidAreaChange', this.handleKeyboard);
    } catch (error) {
      Logger.error(TAG, `Off avoidAreaChange failed, cause code:${error.code}, message:${error.message}`);
    }
  }

  build() {
    Column() {
      TextArea({
        text: this.textStr,
        placeholder: $r('app.string.text_placeholder'),
      })
        .margin({
          left: $r('app.float.common_left_right_margin'),
          right: $r('app.float.common_left_right_margin'),
          bottom: this.contentOffset,
        })
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .enterKeyType(EnterKeyType.Done)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .maxLines(this.textAreaDescriptor.maxLines)
        .attributeModifier(new TextAreaAttributeModifier(this.textAreaDescriptor))
        .animation({
          duration: DetailPageConstant.UP_DURATION,
          curve: Curve.Linear,
          playMode: PlayMode.Normal,
        })
        .onChange((value: string) => {
          this.textStr = value;
        })
    }
    .height('100%')
    .width($r('app.float.multiline_text_width'))
    .justifyContent(FlexAlign.Center)
    .onAreaChange((_: Area, newArea: Area) => {
      this.textAreaInputHeight = Number(newArea.height);
    })
  }
}