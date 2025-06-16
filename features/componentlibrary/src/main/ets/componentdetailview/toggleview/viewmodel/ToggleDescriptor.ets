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
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';
import {
  backgroundColorMapData,
  isOnMapData,
  toggleTypeMapData,
  trackBorderRadiusMapData,
} from '../entity/ToggleAttributeMapping';

@Observed
export class ToggleDescriptor extends CommonDescriptor {
  public toggleType: ToggleType = toggleTypeMapData.get('Default')!.value as ToggleType;
  public trackBorderRadius: number = trackBorderRadiusMapData.get('Default')!.value as number;
  public isOn: boolean = isOnMapData.get('Default')!.value as boolean;
  public backgroundColor: ResourceColor = backgroundColorMapData.get('Default')!.value as ResourceColor;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'toggleType':
          this.toggleType = toggleTypeMapData.get(attribute.currentValue)?.value as ToggleType ??
            toggleTypeMapData.get('Default')!.value as ToggleType;
          break;
        case 'isOn':
          this.isOn = JSON.parse(attribute.currentValue) ?? isOnMapData.get('Default')!.value as boolean;
          break;
        case 'backgroundColor':
          this.backgroundColor = attribute.currentValue;
          break;
        default:
          break;
      }
    });
  }
}