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
  progressColorMapData,
  progressKindMapData,
  progressStyleMapData,
  progressTypeMapData,
  progressValueMapData,
} from '../entity/ProgressAttributeMapping';

@Observed
export class ProgressDescriptor extends CommonDescriptor {
  public value: number = progressValueMapData.get('Default')!.value;
  public color: ResourceColor = progressColorMapData.get('Default')!.value;
  public style: CommonProgressStyleOptions = progressStyleMapData.get('Default')!.value;
  public type: ProgressType = ProgressType.Linear;
  public kind: string = progressKindMapData.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'value':
          this.value = Number(attribute.currentValue);
          break;
        case 'kind':
          this.kind = attribute.currentValue;
          break;
        case 'color':
          this.color = attribute.currentValue;
          break;
        case 'style':
          this.style =
            progressStyleMapData.get(attribute.currentValue)?.value ?? progressStyleMapData.get('Default')!.value;
          this.type = progressTypeMapData.get(attribute.currentValue)?.value ?? ProgressType.Linear;
          break;
        default:
          break;
      }
    });
  }
}