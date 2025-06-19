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

export enum CustomDialogStyle {
  StyleImage = '图文弹窗',
  StyleProgress = '进度弹窗',
}

export const dialogStyleMapData: Map<string, CustomDialogStyle> = new Map([
  ['Default', CustomDialogStyle.StyleImage],
  ['图文弹窗', CustomDialogStyle.StyleImage],
  ['进度弹窗', CustomDialogStyle.StyleProgress],
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
      // 替换自己项目src/main/resources/base/media下的资源图片
      imageRes: $r('app.media.image_dialog'),
      imageSize: {
        width: 'auto',
        height: 180
      },
      title: '带图形确认框',
      content: '必要时可以通过图形化方式展现确认框，以使用户更好理解或认同确认内容',
      isChecked: this.isChecked,
      checkTips: '我已知晓上述内容，不再提醒',
      onCheckedChange: () => {
        this.isChecked = !this.isChecked;
      },
      primaryButton: {
        value: '取消',
        action: () => {
          this.onCancel();
          this.dialogController?.close();
          console.info('Callback when the first button is clicked');
        },
      },
      secondaryButton: {
        value: '确认',
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
        value: '取消',
        action: () => {
          this.onCancel();
          this.dialogController?.close();
        }
      }, {
        value: '确认',
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
        Text('标题')
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