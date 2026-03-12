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

import type { OriginAttribute } from '../../../../viewmodel/Attribute';
import { commonFontColorMap, DEFAULT_KEY, fontWeightMapData } from '../../../common/entity/CommonMapData';
import { CommonCodeGenerator } from '../../../../viewmodel/CommonCodeGenerator';

export class DatePickerCodeGenerator implements CommonCodeGenerator {
  private lunar: boolean = false;
  private selectedTextColor: ResourceColor = commonFontColorMap.get(DEFAULT_KEY)!.code;
  private selectedFontSize: number = 20;
  private selectedFontWeight: string = fontWeightMapData.get(DEFAULT_KEY)!.code;
  private fontSize: number = 16;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'lunar':
          this.lunar = (attribute.currentValue?.toLowerCase() === 'true');
          break;
        case 'selectedTextColor':
          this.selectedTextColor = attribute.currentValue;
          break;
        case 'selectedFontSize':
          const selectedFontSize = Number(attribute.currentValue);
          this.selectedFontSize = Number.isNaN(selectedFontSize) ? this.selectedFontSize : selectedFontSize;
          break;
        case 'selectedFontWeight':
          this.selectedFontWeight =
            fontWeightMapData.get(attribute.currentValue)?.code ?? fontWeightMapData.get(DEFAULT_KEY)!.code;
          break;
        case 'fontSize':
          const fontSize = Number(attribute.currentValue);
          this.fontSize = Number.isNaN(fontSize) ? this.fontSize : fontSize;
          break;
        default:
          break;
      }
    });
    return `@Component
struct DatePickerComponent {
  build() {
    Column() {
      DatePicker({
      start: new Date('1970-1-1'),
      end: new Date('2100-1-1'),
      selected: new Date('2021-08-08')
    })
      .margin({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
        top: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8')
      })
      .lunar(${this.lunar})
      .selectedTextStyle({
        color: '${this.selectedTextColor}',
        font: {
          size: ${this.selectedFontSize},
          weight: ${this.selectedFontWeight}
        }
      })
      .textStyle({
        color: $r('sys.color.font_primary'),
        font: {
          size: ${this.fontSize},
          weight: FontWeight.Regular
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