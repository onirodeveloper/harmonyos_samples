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
import { CommonDescriptor } from '../../../../viewmodel/CommonDescriptor';
import { fontWeightMapData } from '../../../common/entity/CommonMapData';
import {
  calendarAlignTypeMapData,
  EdgeAlign,
  edgeAlignDefault,
  textStyleDefault,
} from '../entity/CalendarPickerAttributeMapping';

@Observed
export class CalendarPickerDescriptor extends CommonDescriptor {
  public edgeAlign: EdgeAlign = edgeAlignDefault;
  public textStyle: PickerTextStyle = textStyleDefault;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'calendarAlignType':
          this.edgeAlign =
            {
              alignType: calendarAlignTypeMapData.get(attribute.currentValue)?.value ?? CalendarAlign.END,
              offset: this.edgeAlign.offset,
            };
          break;
        case 'calendarOffsetX':
          this.edgeAlign =
            {
              alignType: this.edgeAlign.alignType,
              offset: { dx: Number(attribute.currentValue), dy: this.edgeAlign.offset?.dy || 0 },
            };
          break;
        case 'calendarOffsetY':
          this.edgeAlign =
            {
              alignType: this.edgeAlign.alignType,
              offset: { dx: this.edgeAlign.offset?.dx || 0, dy: Number(attribute.currentValue) },
            };
          break;
        case 'pickerFontColor':
          this.textStyle =
            { color: attribute.currentValue, font: this.textStyle.font };
          break;
        case 'pickerFontSize':
          this.textStyle =
            {
              color: this.textStyle.color,
              font: { size: Number(attribute.currentValue), weight: this.textStyle.font?.weight },
            };
          break;
        case 'pickerFontWeight':
          this.textStyle =
            {
              color: this.textStyle.color,
              font: { size: this.textStyle.font?.size, weight: fontWeightMapData.get(attribute.currentValue)?.value },
            };
          break;
        default:
          break;
      }
    });
  }
}