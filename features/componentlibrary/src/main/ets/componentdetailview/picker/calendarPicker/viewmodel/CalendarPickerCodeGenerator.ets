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
import { commonFontColorMap, fontWeightMapData } from '../../../common/entity/CommonMapData';
import { CommonCodeGenerator } from '../../../../viewmodel/CommonCodeGenerator';
import { calendarAlignTypeMapData } from '../entity/CalendarPickerAttributeMapping';

export class CalendarPickerCodeGenerator implements CommonCodeGenerator {
  private calendarOffsetX: number = 0;
  private calendarOffsetY: number = 0;
  private calendarAlignType: string = calendarAlignTypeMapData.get('Default')!.code;
  private pickerFontColor: string = commonFontColorMap.get('Default')!.code;
  private pickerFontSize: number = 16;
  private pickerFontWeight: string = fontWeightMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'calendarAlignType':
          this.calendarAlignType =
            calendarAlignTypeMapData.get(attribute.currentValue)?.code ?? this.calendarAlignType;
          break;
        case 'calendarOffsetX':
          this.calendarOffsetX = Number(attribute.currentValue);
          break;
        case 'calendarOffsetY':
          this.calendarOffsetY = Number(attribute.currentValue);
          break;
        case 'pickerFontColor':
          this.pickerFontColor = attribute.currentValue;
          break;
        case 'pickerFontSize':
          this.pickerFontSize = Number(attribute.currentValue);
          break;
        case 'pickerFontWeight':
          this.pickerFontWeight = fontWeightMapData.get(attribute.currentValue)?.code ?? this.pickerFontWeight;
          break;
        default:
          break;
      }
    });
    return `@Component
struct CalendarPickerComponent {
  build() {
    Column() {
      CalendarPicker({ hintRadius: 10, selected: new Date('2024-03-05') })
        .width('30%')
        .edgeAlign(${this.calendarAlignType}, { dx: ${this.calendarOffsetX}, dy: ${this.calendarOffsetY} })
        .textStyle({ color: '${this.pickerFontColor}', font: { size: ${this.pickerFontSize}, weight: ${this.pickerFontWeight} } })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }
}`;
  }
}