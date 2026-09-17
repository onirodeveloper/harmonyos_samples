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

import { DEFAULT_KEY } from '../../common/entity/CommonMapData';

export enum CustomDialogStyle {
  StyleImage = 'Graphic dialog',
  StyleProgress = 'Progress dialog',
}

export const dialogStyleMapData: Map<string, CustomDialogStyle> = new Map([
  [DEFAULT_KEY, CustomDialogStyle.StyleImage],
  ['Graphic dialog', CustomDialogStyle.StyleImage],
  ['Progress dialog', CustomDialogStyle.StyleProgress],
]);

export const dialogResourceMapData: Map<CustomDialogStyle, ResourceStr> = new Map([
  [CustomDialogStyle.StyleImage, $r('app.string.custom_graphic_dialog')],
  [CustomDialogStyle.StyleProgress, $r('app.string.custom_progress_dialog')],
]);

export const dialogImportCodeMapData: Map<CustomDialogStyle, string> = new Map([
  [CustomDialogStyle.StyleImage, `import { TipsDialog } from '@kit.ArkUI';`],
  [CustomDialogStyle.StyleProgress, `import { CustomContentDialog } from '@kit.ArkUI';`],
]);

export const styleGraphicBuilderCode = `  @Builder
  tipDialogBuilder() {
    TipsDialog({
       // Replace this image with a resource from your project's src/main/resources/base/media directory
      imageRes: $r('app.media.image_dialog'),
      imageSize: {
        width: 'auto',
        height: 180
      },
       title: 'Graphic confirmation dialog',
       content: 'Use a graphic confirmation dialog when visual content helps users understand or confirm the action',
      isChecked: this.isChecked,
       checkTips: 'I understand and do not remind me again',
      onCheckedChange: () => {
        this.isChecked = !this.isChecked;
      },
      primaryButton: {
         value: 'Cancel',
        action: () => {
          this.onCancel();
          this.dialogController?.close();
          console.info('Callback when the first button is clicked');
        },
      },
      secondaryButton: {
         value: 'Confirm',
        action: () => {
          this.onAccept();
          this.dialogController?.close();
          console.info('Callback when the second button is clicked');
        }
      }
    })
  }`;

export const styleProgressBuilderCode: string = `  @Builder
  progressDialogBuilder() {
    CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [{
         value: 'Cancel',
        action: () => {
          this.onCancel();
          this.dialogController?.close();
        }
      }, {
         value: 'Confirm',
        action: () => {
          this.onAccept();
          this.dialogController?.close();
        }
      }]
    })
  }

  @Builder
  buildContent(): void {
    Column() {
      Row() {
         Text('Title')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .textAlign(TextAlign.Start)
        Blank()
        Text('20%')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .width(32)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(20)
      .alignItems(VerticalAlign.Center)

      Progress({ value: 20 })
        .height(24)
        .margin({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level2') })
    }
  }`;

export const dialogBuilderCodeMapData: Map<CustomDialogStyle, string> = new Map([
  [CustomDialogStyle.StyleImage, styleGraphicBuilderCode],
  [CustomDialogStyle.StyleProgress, styleProgressBuilderCode],
]);
