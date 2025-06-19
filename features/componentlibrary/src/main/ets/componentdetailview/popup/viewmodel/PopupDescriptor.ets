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
import { placementMapData, PopupStyle, popupStyleMapData } from '../entity/PopupMapping';

@Observed
export class PopupDescriptor extends CommonDescriptor {
  public placement: Placement = placementMapData.get('Default')!.value;
  public type: PopupStyle = popupStyleMapData.get('Default')!;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'type':
          this.type = popupStyleMapData.get(attribute.currentValue) ?? this.type;
          break;
        case 'placement':
          this.placement = placementMapData.get(attribute.currentValue)?.value ?? this.placement;
          break;
        default:
          break;
      }
    });
  }
}