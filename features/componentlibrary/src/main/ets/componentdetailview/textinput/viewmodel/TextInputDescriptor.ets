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
import { DEFAULT_KEY, highlightColorMap } from '../../common/entity/CommonMapData';
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';
import { textInputFontMapData, textInputTypeMapData } from '../entity/TextInputAttributeMapping';

@Observed
export class TextInputDescriptor extends CommonDescriptor {
  public type: InputType = textInputTypeMapData.get(DEFAULT_KEY)!.value;
  public fontColor: string = highlightColorMap.get(DEFAULT_KEY)!.value;
  public placeholderFont: Font = textInputFontMapData.get(DEFAULT_KEY)!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'type':
          this.type =
            textInputTypeMapData.get(attribute.currentValue)?.value ?? textInputTypeMapData.get(DEFAULT_KEY)!.value;
          break;
        case 'fontColor':
          this.fontColor = attribute.currentValue;
          break;
        case 'placeholderFont':
          this.placeholderFont =
            textInputFontMapData.get(attribute.currentValue)?.value ?? textInputFontMapData.get(DEFAULT_KEY)!.value;
          break;
        default:
          break;
      }
    });
  }
}