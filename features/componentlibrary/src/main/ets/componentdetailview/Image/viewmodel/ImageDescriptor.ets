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
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';
import { filterStyleMapData, imageFitStyleMapData } from '../entity/ImageAttributeMapping';

@Observed
export class ImageDescriptor extends CommonDescriptor {
  private colorFilterMatrixStr: string = filterStyleMapData.get('Default')!.value;
  public objectFit: ImageFit = imageFitStyleMapData.get('Default')!.value;
  public colorFilterMatrix: number[] = StringUtil.stringToArray(this.colorFilterMatrixStr);
  public clip: boolean = false;


  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'objectFit':
          this.objectFit =
            imageFitStyleMapData.get(attribute.currentValue)?.value ?? imageFitStyleMapData.get('Default')!.value;
          break;
        case 'colorFilterMatrixStr':
          this.colorFilterMatrixStr =
            filterStyleMapData.get(attribute.currentValue)?.value ?? filterStyleMapData.get('Default')!.value;
          this.colorFilterMatrix = StringUtil.stringToArray(this.colorFilterMatrixStr);
          break;
        case 'clip':
          this.clip = JSON.parse(attribute.currentValue);
          break;
        default:
          break;
      }
    });
  }
}