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
import { fontWeightMapData } from '../../../common/entity/CommonMapData';
import { CommonDescriptor } from '../../../../viewmodel/CommonDescriptor';

@Observed
export class DatePickerDescriptor extends CommonDescriptor {
  public lunar: boolean = false;
  public selectedTextStyle: PickerTextStyle = {
    color: $r('app.color.date_picker_default_color'),
    font: {
      size: 20,
      weight: FontWeight.Medium,
    },
  };
  public textStyle: PickerTextStyle = {
    color: $r('sys.color.font_primary'),
    font: {
      size: 16,
      weight: FontWeight.Regular,
    },
  };

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'lunar':
          this.lunar = JSON.parse(attribute.currentValue);
          break;
        case 'selectedTextColor':
          this.selectedTextStyle = {
            color: attribute.currentValue,
            font: {
              size: this.selectedTextStyle.font?.size,
              weight: this.selectedTextStyle.font?.weight,
            },
          };
          break;
        case 'selectedFontSize':
          this.selectedTextStyle = {
            color: this.selectedTextStyle.color,
            font: {
              size: Number(attribute.currentValue),
              weight: this.selectedTextStyle.font?.weight,
            },
          };
          break;
        case 'selectedFontWeight':
          this.selectedTextStyle = {
            color: this.selectedTextStyle.color,
            font: {
              size: this.selectedTextStyle.font?.size,
              weight: fontWeightMapData.get(attribute.currentValue)?.value ?? this.selectedTextStyle.font?.weight,
            },
          };
          break;
        case 'fontSize':
          this.textStyle.font = {
            size: Number(attribute.currentValue),
            weight: FontWeight.Regular,
          };
          break;
        default:
          break;
      }
    });
  }
}