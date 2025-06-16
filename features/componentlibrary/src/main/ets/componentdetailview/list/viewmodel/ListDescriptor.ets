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
import { edgeEffectMapData, LanesStyle, listDirectionMapData } from '../entity/ListAttributeMapping';

@Observed
export class ListDescriptor extends CommonDescriptor {
  public listDirection: Axis = listDirectionMapData.get('Default')!.value;
  public lanes: LanesStyle = {
    value: 1,
    gutter: 0,
  };
  public edgeEffect: EdgeEffect = edgeEffectMapData.get('Default')!.value;
  public sticky: boolean = true;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'listDirection':
          this.listDirection =
            listDirectionMapData.get(attribute.currentValue)?.value ?? listDirectionMapData.get('Default')!.value;
          break;
        case 'lanesNum':
          this.lanes = {
            value: Number(attribute.currentValue),
            gutter: this.lanes.gutter,
          };
          break;
        case 'gutter':
          this.lanes = {
            value: this.lanes.value,
            gutter: Number(attribute.currentValue),
          };
          break;
        case 'edgeEffect':
          this.edgeEffect =
            edgeEffectMapData.get(attribute.currentValue)?.value ?? edgeEffectMapData.get('Default')!.value;
          break;
        case 'sticky':
          this.sticky = JSON.parse(attribute.currentValue);
          break;
        default:
          break;
      }
    });
  }
}