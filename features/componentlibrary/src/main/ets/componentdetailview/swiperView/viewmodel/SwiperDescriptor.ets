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
import { indicatorEffectMapping, indicatorStyleMapData } from '../entity/SwiperAttributeMapping';

@Observed
export class SwiperDescriptor extends CommonDescriptor {
  public indicator: DotIndicator | DigitIndicator | boolean = indicatorStyleMapData.get('Default')!.value;
  public vertical: boolean = false;
  public effectMode: EdgeEffect = indicatorEffectMapping.get('Default')!.value;
  public isDisplayArrow: boolean = true;
  public displayArrow: ArrowStyle | boolean = false;
  public loop: boolean = true;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'indicator':
          this.indicator = indicatorStyleMapData.get(attribute.currentValue)?.value ?? this.indicator;
          break;
        case 'vertical':
          this.vertical = JSON.parse(attribute.currentValue);
          break;
        case 'effectMode':
          this.effectMode = indicatorEffectMapping.get(attribute.currentValue)?.value ?? this.effectMode;
          break;
        case 'isDisplayArrow':
          this.isDisplayArrow = JSON.parse(attribute.currentValue);
          if (this.isDisplayArrow) {
            this.displayArrow = {
              showBackground: true,
              isSidebarMiddle: true,
              backgroundSize: 24,
              backgroundColor: Color.White,
              arrowSize: 18,
              arrowColor: Color.Blue
            };
          } else {
            this.displayArrow = false;
          }
          break;
        case 'loop':
          this.loop = JSON.parse(attribute.currentValue);
          break;
        default:
          break;
      }
    });
  }
}