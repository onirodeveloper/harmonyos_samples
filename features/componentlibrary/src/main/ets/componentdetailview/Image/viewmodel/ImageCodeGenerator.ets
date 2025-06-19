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

import { StringUtil } from '../../../util/StringUtil';
import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import { filterStyleMapData, imageFitStyleMapData } from '../entity/ImageAttributeMapping';

export class ImageCodeGenerator implements CommonCodeGenerator {
  private objectFit: string = imageFitStyleMapData.get('Default')!.code;
  private clip: boolean = false;
  private colorFilterMatrixStr: string = filterStyleMapData.get('Default')!.code;
  private colorFilterMatrix: number[] = StringUtil.stringToArray(this.colorFilterMatrixStr);

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'objectFit':
          this.objectFit =
            imageFitStyleMapData.get(attribute.currentValue)?.code ?? imageFitStyleMapData.get('Default')!.code;
          break;
        case 'colorFilterMatrixStr':
          this.colorFilterMatrixStr =
            filterStyleMapData.get(attribute.currentValue)?.code ?? filterStyleMapData.get('Default')!.code;
          this.colorFilterMatrix = StringUtil.stringToArray(this.colorFilterMatrixStr);
          break;
        case 'clip':
          this.clip = JSON.parse(attribute.currentValue);
          break;
        default:
          break;
      }
    });
    return `@Component
struct ImageComponent {
  build() {
    Column() {
      // You need to place a PNG format image in the media folder.
      Image($r('app.media.image_src340'))
        .colorFilter(new ColorFilter([${this.colorFilterMatrix}]))
        .objectFit(${this.objectFit})
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width('200vp')
    .height('140vp')
    .clip(${this.clip})
  }
}`;
  }
}