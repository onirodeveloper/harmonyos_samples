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
  indicatorMapData,
  ratingValueMapData,
  starsMapData,
  starStyleMapData,
} from '../entity/RatingAttributeMapping';

@Observed
export class RatingDescriptor extends CommonDescriptor {
  public rating: number = ratingValueMapData.get('Default')!.value as number;
  public indicator: boolean = indicatorMapData.get('Default')!.value as boolean;
  public stars: number = starsMapData.get('Default')!.value as number;
  public stepSize: number = 0.5;
  public starStyle: boolean = starStyleMapData.get('Default')!.value as boolean;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'rating':
          this.rating = Number(attribute.currentValue) ?? ratingValueMapData.get('Default')!.value as number;
          break;
        case 'indicator':
          this.indicator = attribute.currentValue.toLowerCase() === 'true';
          break;
        case 'stars':
          this.stars = Number(attribute.currentValue) ?? starsMapData.get('Default')!.value as number;
          break;
        case 'starStyle':
          this.starStyle = attribute.currentValue.toLowerCase() === 'true';
          break;
        default:
          break;
      }
    });
  }
}