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

import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { alertDialogAlignmentMapData } from '../entity/AlertDialogAttributeMapping';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class AlertDialogCodeGenerator implements CommonCodeGenerator {
  private alertDialogAlignment: string = alertDialogAlignmentMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'dialogAlignment':
          this.alertDialogAlignment =
            alertDialogAlignmentMapData.get(attribute.currentValue)?.code ?? this.alertDialogAlignment;
          break;
        default:
          break;
      }
    });
    return `import { promptAction } from '@kit.ArkUI';

@Component
struct AlertDialogComponent {
  build() {
    Column({ space: 5 }) {
      Button('点击警告弹窗')
        .buttonStyle(ButtonStyleMode.NORMAL)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          AlertDialog.show(
            {
              title: '标题',
              subtitle: '副标题',
              message: '内容',
              autoCancel: true,
              alignment: ${this.alertDialogAlignment},
              offset: { dx: 0, dy: -20 },
              buttonDirection: DialogButtonDirection.HORIZONTAL,
              buttons: [
                {
                  value: '按钮1',
                  action: () => {
                    try {
                      promptAction.showToast({
                        message: 'Callback when button1 is clicked',
                        duration: 2000
                      });
                    } catch (err) {
                      const error: BusinessError = err as BusinessError;
                      console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                    }
                  }
                },
                {
                  value: '按钮2',
                  action: () => {
                    try {
                      promptAction.showToast({
                        message: 'Callback when button2 is clicked',
                        duration: 2000
                      });
                    } catch (err) {
                      const error: BusinessError = err as BusinessError;
                      console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                    }
                  }
                }
              ],
              cancel: () => {
                console.log('Closed callbacks');
              },
              onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                  dismissDialogAction.dismiss();
                }
                if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                  dismissDialogAction.dismiss();
                }
              }
            })
        })
    }
    .width('100%')
  }
}`;
  }
}