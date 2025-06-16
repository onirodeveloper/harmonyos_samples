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
import { fontWeightMapData } from '../../common/entity/CommonMapData';
import {
  fontColorMapData,
  fontSizeMapData,
  letterSpacingMapData,
  opacityMapData,
  textShadowRadiusMapData,
} from '../entity/TextAttributeMapping';

@Observed
export class TextDescriptor extends CommonDescriptor {
  public fontWeight: FontWeight = fontWeightMapData.get('Default')!.value as FontWeight;
  public fontSize: number | string = fontSizeMapData.get('Default')!.value as number;
  public fontColor: ResourceColor = fontColorMapData.get('Default')!.value as string;
  public opacity: number = opacityMapData.get('Default')!.value as number;
  public letterSpacing: number = letterSpacingMapData.get('Default')!.value as number;
  public textShadowRadius: number = textShadowRadiusMapData.get('Default')!.value as number;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'fontWeight':
          this.fontWeight = (fontWeightMapData.get(attribute.currentValue)?.value ??
          fontWeightMapData.get('Default')!.value) as FontWeight;
          break;
        case 'fontColor':
          this.fontColor = attribute.currentValue;
          break;
        case 'fontSize':
          this.fontSize = Number(attribute.currentValue);
          break;
        case 'opacity':
          this.opacity = Number(attribute.currentValue);
          break;
        case 'letterSpacing':
          this.letterSpacing = Number(attribute.currentValue);
          break;
        case 'textShadowRadius':
          this.textShadowRadius = Number(attribute.currentValue);
          break;
        default:
          break;
      }
    });
  }
}