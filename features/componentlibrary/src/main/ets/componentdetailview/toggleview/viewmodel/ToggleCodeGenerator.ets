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
import { backgroundColorMapData, isOnMapData, toggleTypeMapData } from '../entity/ToggleAttributeMapping';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class ToggleCodeGenerator implements CommonCodeGenerator {
  private toggleType: string = toggleTypeMapData.get('Default')!.code;
  private isOn: string = isOnMapData.get('Default')!.code;
  private backgroundColor: string = backgroundColorMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'toggleType':
          this.toggleType =
            toggleTypeMapData.get(attribute.currentValue)?.code ?? toggleTypeMapData.get('Default')!.code;
          break;
        case 'isOn':
          this.isOn = JSON.parse(attribute.currentValue);
          break;
        case 'backgroundColor':
          this.backgroundColor = attribute.currentValue;
          break;
        default:
          break;
      }
    });
    const codeOne = this.toggleType === 'ToggleType.Switch' ? `
      Text('Switch样式')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
      Blank()` : '';
    if (this.toggleType === 'ToggleType.Button') {
      return `@Component
struct ToggleComponent {
  // You can view different styles by changing the toggleType.
  build() {
    Row() {${codeOne}
       Toggle({
        type: ${this.toggleType},
        isOn: ${this.isOn}
      }){
          Text('状态按钮')
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(12)
        }
      .selectedColor('${this.backgroundColor}')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: $r('sys.float.padding_level16'), right: $r('sys.float.padding_level16') })
  }
}`;
    } else {
      return `@Component
struct ToggleComponent {
  // You can view different styles by changing the toggleType.
  build() {
    Row() {${codeOne}
       Toggle({
        type: ${this.toggleType},
        isOn: ${this.isOn}
      })
      .selectedColor('${this.backgroundColor}')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: $r('sys.float.padding_level16'), right: $r('sys.float.padding_level16') })
  }
}`
    }
  }
}