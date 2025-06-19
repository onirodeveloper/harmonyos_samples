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
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class DocumentViewPickerCodeGenerator implements CommonCodeGenerator {
  public generate(_attributes: OriginAttribute[]): string {
    return `import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import type { BusinessError } from '@kit.BasicServicesKit';

@Component
struct DocumentViewPickerComponent {
  @State message: string = '';
  @State title: string = '';

  build() {
    Column() {
      Button('选择文件')
        .backgroundColor($r('sys.color.background_secondary'))
        .width(120)
        .height(40)
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          let context = getContext(this) as common.Context;
          try {
            const documentSelectOptions = new picker.DocumentSelectOptions();
            const documentPicker = new picker.DocumentViewPicker(context);
            documentPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
              this.message = JSON.stringify(documentSelectResult);
              if (documentSelectResult.length === 0) {
                return;
              }
              this.getUIContext().showAlertDialog(
                {
                  title: '文件路径',
                  message: this.message,
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  offset: { dx: 0, dy: -20 },
                  gridCount: 3,
                  width: 300,
                  height: 300,
                  cornerRadius: $r('sys.float.corner_radius_level7'),
                  borderWidth: 1,
                  borderStyle: BorderStyle.Dashed,
                  borderColor: Color.Blue,
                  backgroundColor: Color.White,
                  textStyle: { wordBreak: WordBreak.BREAK_ALL },
                  confirm: {
                    value: '确定',
                    action: () => {
                      console.log('Confirm button is clicked.');
                    },
                  },
                  onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                    if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                      dismissDialogAction.dismiss();
                    }
                    if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                      dismissDialogAction.dismiss();
                    }
                  }
                }
              )
            }).catch((err: BusinessError) => {
              console.error(\`DocumentViewPicker.select failed with err: \${err.code}, \${err.message}\`);
            });
          } catch (error) {
            const err: BusinessError = error as BusinessError;
            console.error(\`DocumentViewPicker failed with err: \${err.code}, \${err.message}\`);
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}`;
  }
}