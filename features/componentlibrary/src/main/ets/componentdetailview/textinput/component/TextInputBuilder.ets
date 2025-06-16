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
import { GlobalInfoModel, Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { ComponentDetailManager } from '../../../viewmodel/ComponentDetailManager';
import { AttributeChangeEnable } from '../../../viewmodel/ComponentDetailPageVM';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { TextInputAttributeModifier } from '../viewmodel/TextInputAttributeModifier';
import type { TextInputDescriptor } from '../viewmodel/TextInputDescriptor';

const TAG: string = '[TextInputBuilder]';

@Builder
export function TextInputBuilder($$: DescriptorWrapper) {
  TextInputComponent({ textInputComponentDescriptor: $$.descriptor as TextInputDescriptor })
}

@Component
struct TextInputComponent {
  @Prop textInputComponentDescriptor: TextInputDescriptor;
  @State isText: boolean = false;
  @State textInputHeight: number = 0;
  @State contentOffset: number = 0;

  aboutToAppear(): void {
    ComponentDetailManager.getInstance()
      .getDetailViewModel('TextInput')?.sendEvent(new AttributeChangeEnable('fontColor', this.isText));
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel') || new GlobalInfoModel();
    let keyboardHeight: number = 0;

    window.getLastWindow(getContext(this)).then(currentWindow => {
      // Monitor the appearance and disappearance of the soft keyboard.
      try {
        currentWindow.on('avoidAreaChange', async data => {
          if (data.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
            return;
          }
          keyboardHeight = px2vp(data.area.bottomRect.height);
          /* When the size of the component preview area exceeds half the screen, the keyboard
           will cover the preview area. At this time, the component needs to move up when the keyboard appears.
           */
          if (keyboardHeight > 0 && this.textInputHeight / globalInfoModel.deviceHeight > 0.5) {
            this.contentOffset = keyboardHeight / 2;
          } else {
            this.contentOffset = 0;
          }
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `CurrentWindow invoke error, the code is ${error.message}, the message is ${error.message}`);
      }
    });
  }

  handleAttributeChange() {
    ComponentDetailManager.getInstance()
      .getDetailViewModel('TextInput')?.sendEvent(new AttributeChangeEnable('fontColor', !this.isText));
    ComponentDetailManager.getInstance()
      .getDetailViewModel('TextInput')?.sendEvent(new AttributeChangeEnable('placeholderFont', this.isText));
    this.isText = !this.isText;
  }

  build() {
    Column() {
      TextInput({ placeholder: $r('app.string.text_placeholder') })
        .margin({
          left: $r('app.float.common_left_right_margin'),
          right: $r('app.float.common_left_right_margin'),
          bottom: this.contentOffset,
        })
        .height($r('app.float.common_component_height'))
        .onChange((value: string) => {
          if ((value.trim().length === 0 && this.isText) || (value.trim().length !== 0 && !this.isText)) {
            this.handleAttributeChange();
          }
        })
        .fontColor(this.textInputComponentDescriptor.fontColor)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .enterKeyType(EnterKeyType.Done)
        .borderRadius($r('sys.float.corner_radius_level12'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .caretStyle({ color: $r('sys.color.font_emphasize') })
        .placeholderFont(this.textInputComponentDescriptor.placeholderFont)
        .attributeModifier(new TextInputAttributeModifier(this.textInputComponentDescriptor))
        .animation({
          duration: DetailPageConstant.UP_DURATION,
          curve: Curve.Linear,
          playMode: PlayMode.Normal,
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .onAreaChange((_: Area, newArea: Area) => {
      this.textInputHeight = Number(newArea.height);
    })
  }
}