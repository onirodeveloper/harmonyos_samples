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
  canLoopMapData,
  itemHeightMapData,
  pickerDataCode,
} from '../entity/TextDialogAttributeMapping';

export class TextPickerDialogCodeGenerator implements CommonCodeGenerator {
  private canLoop: string = canLoopMapData.get('Default')!.code;
  private itemHeight: string = itemHeightMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'canLoop':
          this.canLoop = attribute.currentValue;
          break;
        case 'itemHeight':
          this.itemHeight = attribute.currentValue;
          break;
        default:
          break;
      }
    });
    return `import { promptAction } from '@kit.ArkUI';

@Component
struct TextPickerComponent {
  build() {
    Column() {
      Button('文本选择器弹窗')
        .margin($r('sys.float.padding_level10'))
        .buttonStyle(ButtonStyleMode.NORMAL)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          TextPickerDialog.show({
            range: ${pickerDataCode},
            defaultPickerItemHeight: ${this.itemHeight},
            canLoop: ${this.canLoop},
            onAccept: (value: TextPickerResult) => {
              try {
                promptAction.showToast({
                  message: \`Select \${value.value}\`,
                  duration: 200
                });
              } catch (err) {
                const error: BusinessError = err as BusinessError;
                console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
              }
            },
            onCancel: () => {
              try {
                promptAction.showToast({
                  message: 'Canceled',
                  duration: 200
                });
              } catch (err) {
                const error: BusinessError = err as BusinessError;
                console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
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