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
import { textAlignTypeMapData, textOverflowTypeMapData } from '../entity/TextAreaAttributeMapping';

@Observed
export class TextAreaDescriptor extends CommonDescriptor {
  public maxLines: number = 2;
  public lineSpacing: number = 5;
  public textOverflowTypeData: TextOverflow = textOverflowTypeMapData.get('Default')!.value;
  public textAlign: TextAlign = textAlignTypeMapData.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'maxLines':
          this.maxLines = Number(attribute.currentValue);
          break;
        case 'lineSpacing':
          this.lineSpacing = Number(attribute.currentValue);
          break;
        case 'textOverflowType':
          this.textOverflowTypeData =
            textOverflowTypeMapData.get(attribute.currentValue)?.value ?? textOverflowTypeMapData.get('Default')!.value;
          break;
        case 'textAlign':
          this.textAlign =
            textAlignTypeMapData.get(attribute.currentValue)?.value ?? textAlignTypeMapData.get('Default')!.value;
          break;
        default:
          break;
      }
    });
  }
}