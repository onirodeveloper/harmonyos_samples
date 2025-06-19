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
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import { indicatorMapData, ratingValueMapData, starsMapData } from '../entity/RatingAttributeMapping';

export class RatingCodeGenerator implements CommonCodeGenerator {
  private rating: string = ratingValueMapData.get('Default')!.code;
  private indicator: string = indicatorMapData.get('Default')!.code;
  private stars: string = starsMapData.get('Default')!.code;
  private stepSize: string = '0.5';

  public generate(attributes: OriginAttribute[]): string {
    let codeSegment = ``;
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'rating':
          this.rating = attribute.currentValue;
          break;
        case 'indicator':
          this.indicator = attribute.currentValue.toLowerCase();
          break;
        case 'stars':
          this.stars = attribute.currentValue;
          break;
        case 'starStyle':
          const bool = attribute.currentValue.toLowerCase() === 'true';
          codeSegment = bool ? `{
        // You need to replace the starStyle resource image in the media folder.
        backgroundUri: '/resources/base/media/rating_background.png',
        foregroundUri: '/resources/base/media/rating_foreground.png',
      }` : `{
        backgroundUri: undefined,
        foregroundUri: undefined,
      }`;
          break;
        default:
          break;
      }
    });
    return `@Component
struct RatingComponent {
  build() {
    Rating({ rating: ${this.rating}, indicator: ${this.indicator}})
      .stars(${this.stars})
      .stepSize(${this.stepSize})
      .starStyle(${codeSegment})
  }
}`;
  }
}