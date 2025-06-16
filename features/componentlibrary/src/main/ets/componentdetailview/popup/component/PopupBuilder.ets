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

import { Popup } from '@kit.ArkUI';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { popupBtnTextCodeMapData, PopupStyle } from '../entity/PopupMapping';
import type { PopupDescriptor } from '../viewmodel/PopupDescriptor';

@Builder
export function PopupBuilder($$: DescriptorWrapper) {
  PopupComponent({ popupDescriptor: $$.descriptor as PopupDescriptor })
}

@Component
struct PopupComponent {
  @Prop popupDescriptor: PopupDescriptor;
  @State handlePopup: boolean = false;

  @Builder
  popupWithButtonBuilder(type: PopupStyle) {
    Row() {
      if (type === PopupStyle.STYLE_BUTTON) {
        this.popupButton();
      } else if (type === PopupStyle.STYLE_TEXT) {
        this.popupText();
      } else if (type === PopupStyle.STYLE_ICON) {
        this.popupIcon();
      }
    }
    .onKeyPreIme((keyEvent: KeyEvent) => {
      if ((keyEvent?.keyText === 'KEYCODE_DPAD_RIGHT' || keyEvent?.keyText === 'KEYCODE_DPAD_LEFT') &&
        keyEvent.type === KeyType.Down) {
        return true;
      }
      return false;
    })
  }

  @Builder
  popupButton() {
    Popup({
      title: {
        text: $r('app.string.title'),
      },
      message: {
        text: $r('app.string.popup_button_message'),
      },
      showClose: true,
      onClose: () => {
        this.handlePopup = false;
      },
      buttons: [
        {
          text: $r('app.string.confirmTip'),
          action: () => {
            this.handlePopup = false;
          },
        },
      ],
    })
  }

  @Builder
  popupText() {
    Popup({
      message: {
        text: $r('app.string.popup_text_message')
      },
      showClose: true,
      onClose: () => {
        this.handlePopup = false;
      },
    })
  }

  @Builder
  popupIcon() {
    Popup({
      icon: {
        image: $r('app.media.startIcon')
      },
      title: {
        text: $r('app.string.title'),
      },
      message: {
        text: $r('app.string.popup_icon_message')
      },
      showClose: true,
      onClose: () => {
        this.handlePopup = false;
      },
    })
  }

  build() {
    Column() {
      Button(popupBtnTextCodeMapData.get(this.popupDescriptor.type)!)
        .backgroundColor($r('sys.color.background_secondary'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          this.handlePopup = true;
        })
        .bindPopup(this.handlePopup, {
          builder: this.popupWithButtonBuilder(this.popupDescriptor.type),
          placement: this.popupDescriptor.placement,
          focusable: true,
          width: this.popupDescriptor.type === PopupStyle.STYLE_TEXT ? undefined : $r('app.float.popup_width_large'),
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.handlePopup = false;
            }
          },
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}