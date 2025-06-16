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
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';

@Observed
export class ButtonDescriptor extends CommonDescriptor {
  public buttonStyle: ButtonStyleMode = styleMapData.get('Default')!.value;
  public controlSize: ControlSize = sizeMapData.get('Default')!.value;
  public buttonType: ButtonType = buttonTypeMapData.get('Default')!.value;
  public backgroundColor: ResourceColor = buttonBgColorMap.get('Default')!.value;
  public operation: string = buttonActionMap.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'buttonStyle':
          this.buttonStyle = styleMapData.get(attribute.currentValue)?.value ?? styleMapData.get('Default')!.value;
          break;
        case 'controlSize':
          this.controlSize = sizeMapData.get(attribute.currentValue)?.value ?? sizeMapData.get('Default')!.value;
          break;
        case 'buttonType':
          this.buttonType =
            buttonTypeMapData.get(attribute.currentValue)?.value ?? buttonTypeMapData.get('Default')!.value;
          break;
        case 'backgroundColor':
          if (this.buttonStyle === ButtonStyleMode.EMPHASIZED) {
            this.backgroundColor = attribute.currentValue;
          } else if (this.buttonStyle === ButtonStyleMode.NORMAL) {
            this.backgroundColor = $r('sys.color.comp_background_tertiary');
          } else {
            this.backgroundColor = Color.Transparent;
          }
          break;
        case 'operation':
          this.operation = attribute.currentValue;
          break;
        default:
          break;
      }
    });
  }
}