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

import { CustomContentDialog, TipsDialog } from '@kit.ArkUI';
import { Logger } from '@ohos/common';
import { CustomDialogStyle, dialogResourceMapData } from '../entity/CustomDialogAttributeMapping';
import type { CustomDialogDescriptor } from '../viewmodel/CustomDialogDescriptor';

const TAG: string = '[CustomDialogComponent]';
const PROGRESS_VALUE: number = 20;

@Component
export struct CustomDialogComponent {
  @Prop customDialogDescriptor: CustomDialogDescriptor;
  @State isChecked: boolean = true;
  private tipDialogController?: CustomDialogController = new CustomDialogController({
    builder: this.tipDialogBuilder,
    cancel: this.existApp,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    autoCancel: true,
    cornerRadius: $r('sys.float.padding_level10'),
  });
  private progressDialogController?: CustomDialogController = new CustomDialogController({
    builder: this.progressDialogBuilder,
    cancel: this.existApp,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    autoCancel: true,
    cornerRadius: $r('sys.float.padding_level10'),
  });

  @Builder
  tipDialogBuilder() {
    TipsDialog({
      imageRes: $r('app.media.image_dialog'),
      imageSize: {
        width: 'auto',
        height: $r('app.float.dialog_contain_image_height'),
      },
      title: $r('app.string.dialog_graphic_title'),
      content: $r('app.string.dialog_graphic_content'),
      isChecked: this.isChecked,
      checkTips: $r('app.string.dialog_graphic_tip'),
      onCheckedChange: () => {
        this.isChecked = !this.isChecked;
      },
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        action: () => {
          this.onCancel();
          this.tipDialogController?.close();
        },
      },
      secondaryButton: {
        value: $r('app.string.dialog_confirm'),
        action: () => {
          this.onAccept();
          this.tipDialogController?.close();
        },
      },
    })
  }

  @Builder
  progressDialogBuilder() {
    CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.onCancel();
            this.progressDialogController?.close();
          },
        }, {
        value: $r('app.string.dialog_confirm'),
        action: () => {
          this.onAccept();
          this.progressDialogController?.close();
        },
      },
      ],
    })
  }

  @Builder
  buildContent(): void {
    Column() {
      Row() {
        Text($r('app.string.title'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .textAlign(TextAlign.Start)
        Blank()
        Text($r('app.string.dialog_progress', PROGRESS_VALUE))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .width($r('app.float.text_height_large'))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height($r('app.float.dialog_text_height'))
      .alignItems(VerticalAlign.Center)

      Progress({ value: PROGRESS_VALUE })
        .height($r('app.float.dialog_progress_height'))
        .margin({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level2') })
    }
  }

  aboutToDisappear() {
    this.tipDialogController = undefined;
    this.progressDialogController = undefined;
  }

  onCancel() {
    Logger.info(TAG, 'Callback when the first button is clicked');
  }

  onAccept() {
    Logger.info(TAG, 'Callback when the second button is clicked');
  }

  existApp() {
    Logger.info(TAG, 'Click the callback in the blank area');
  }

  build() {
    Column() {
      Button(dialogResourceMapData.get(this.customDialogDescriptor.style))
        .buttonStyle(ButtonStyleMode.NORMAL)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          if (this.customDialogDescriptor.style === CustomDialogStyle.StyleProgress) {
            this.progressDialogController?.open();
          } else {
            this.tipDialogController?.open();
          }
        })
    }
  }
}