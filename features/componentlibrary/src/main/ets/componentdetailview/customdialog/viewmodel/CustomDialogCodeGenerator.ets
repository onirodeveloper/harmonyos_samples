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
import {
  CustomDialogStyle,
  dialogBuilderCodeMapData,
  dialogImportCodeMapData,
  dialogStyleMapData,
} from '../entity/CustomDialogAttributeMapping';

export class CustomDialogCodeGenerator implements CommonCodeGenerator {
  private style: CustomDialogStyle = dialogStyleMapData.get('Default')!;

  public generate(attributes: OriginAttribute[]): string {
    let builderParamCode: string = 'this.tipDialogBuilder';
    let isCheckedParamCode: string = '';
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'style':
          this.style = dialogStyleMapData.get(attribute.currentValue) ?? this.style;
          if (this.style === CustomDialogStyle.StyleProgress) {
            builderParamCode = 'this.progressDialogBuilder';
            isCheckedParamCode = '';
          } else {
            builderParamCode = 'this.tipDialogBuilder';
            isCheckedParamCode = `
  @State isChecked: boolean = true;`;
          }
          break;
        default:
          break;
      }
    });
    return `${dialogImportCodeMapData.get(this.style)}

@Component
export struct CustomDialogComponent {${isCheckedParamCode}
  private dialogController: CustomDialogController | undefined = new CustomDialogController({
    builder: ${builderParamCode},
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
    cornerRadius: $r('sys.float.padding_level10')
  });

${dialogBuilderCodeMapData.get(this.style)}

  aboutToDisappear() {
    this.dialogController = undefined;
  }

  onCancel() {
    console.info('Callback when the first button is clicked');
  }

  onAccept() {
    console.info('Callback when the second button is clicked');
  }

  existApp() {
    console.info('Click the callback in the blank area');
  }

  build() {
    Column() {
      Button('自定义${this.style}')
        .buttonStyle(ButtonStyleMode.NORMAL)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          this.dialogController?.open();
        })
    }
    .width('100%')
  }
}`
  }
}