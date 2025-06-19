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
import { highlightColorMap } from '../../common/entity/CommonMapData';
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';
import { textInputFontMapData, textInputTypeMapData } from '../entity/TextInputAttributeMapping';

@Observed
export class TextInputDescriptor extends CommonDescriptor {
  public type: InputType = textInputTypeMapData.get('Default')!.value;
  public fontColor: string = highlightColorMap.get('Default')!.value;
  public placeholderFont: Font = textInputFontMapData.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'type':
          this.type =
            textInputTypeMapData.get(attribute.currentValue)?.value ?? textInputTypeMapData.get('Default')!.value;
          break;
        case 'fontColor':
          this.fontColor = attribute.currentValue;
          break;
        case 'placeholderFont':
          this.placeholderFont =
            textInputFontMapData.get(attribute.currentValue)?.value ?? textInputFontMapData.get('Default')!.value;
          break;
        default:
          break;
      }
    });
  }
}