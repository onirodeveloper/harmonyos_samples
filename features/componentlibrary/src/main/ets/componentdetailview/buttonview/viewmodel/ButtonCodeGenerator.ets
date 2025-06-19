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
import {
  buttonActionMap,
  buttonBgColorMap,
  buttonTypeMapData,
  sizeMapData,
  styleMapData,
} from '../entity/ButtonAttributeMapping';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class ButtonCodeGenerator implements CommonCodeGenerator {
  private buttonStyle: string = styleMapData.get('Default')!.code;
  private controlSize: string = sizeMapData.get('Default')!.code;
  private buttonType: string = buttonTypeMapData.get('Default')!.code;
  private backgroundColor: string = buttonBgColorMap.get('Default')!.code;
  private operation: string = buttonActionMap.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'buttonStyle':
          this.buttonStyle = styleMapData.get(attribute.currentValue)?.code ?? styleMapData.get('Default')!.code;
          break;
        case 'controlSize':
          this.controlSize = sizeMapData.get(attribute.currentValue)?.code ?? sizeMapData.get('Default')!.code;
          break;
        case 'buttonType':
          this.buttonType =
            buttonTypeMapData.get(attribute.currentValue)?.code ?? buttonTypeMapData.get('Default')!.code;
          break;
        case 'backgroundColor':
          this.backgroundColor = attribute.currentValue;
          if (this.buttonStyle === styleMapData.get('Emphasized')!.code) {
            this.backgroundColor = `'${attribute.currentValue}'`;
          } else if (this.buttonStyle === styleMapData.get('Normal')!.code) {
            this.backgroundColor = `$r('sys.color.comp_background_tertiary')`;
          } else {
            this.backgroundColor = `Color.Transparent`;
          }
          break;
        case 'operation':
          this.operation = attribute.currentValue;
          break;
        default:
          break;
      }
    });
    let operationCode: string = '';
    if (this.operation === 'LongGesture') {
      operationCode = `.gesture(
        LongPressGesture({ repeat: true })
          .onActionEnd((event: GestureEvent) => {
            try {
              promptAction.showToast({
                message: '按钮被长按',
                duration: 2000
              });
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
            }
          })
      )`;
    } else if (this.operation === 'Click') {
      operationCode = `.onClick(() => {
        try {
          promptAction.showToast({
            message: '按钮被点击',
            duration: 2000
          });
        } catch (err) {
          const error: BusinessError = err as BusinessError;
          console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
        }
      })`;
    } else {
      operationCode = ``;
    }
    return `import { promptAction } from '@kit.ArkUI';

@Component
struct ButtonComponent {
  build() {
    Button('按钮示例', { type: ${this.buttonType} })
      .buttonStyle(${this.buttonStyle})
      .controlSize(${this.controlSize})
      .backgroundColor(${this.backgroundColor})
      ${operationCode}
  }
}`;
  }
}