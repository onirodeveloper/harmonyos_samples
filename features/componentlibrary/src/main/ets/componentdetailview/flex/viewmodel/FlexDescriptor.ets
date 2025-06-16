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
  ElementsNums,
  elementsNumsMapData,
  flexAlignItemMapData,
  flexContentMapData,
  flexDirectionMapData,
  flexWrapMapData,
} from '../entity/FlexAttributeMapping';

@Observed
export class FlexDescriptor extends CommonDescriptor {
  public elements: ElementsNums = elementsNumsMapData.get('Default')!.value as ElementsNums;
  public direction: FlexDirection = flexDirectionMapData.get('Default')!.value as FlexDirection;
  public wrap: FlexWrap = flexWrapMapData.get('Default')!.value as FlexWrap;
  public justifyContent: FlexAlign = flexContentMapData.get('Default')!.value as FlexAlign;
  public alignItems: ItemAlign = flexAlignItemMapData.get('Default')!.value as ItemAlign;
  public alignSelf: ItemAlign = flexAlignItemMapData.get('Default')!.value as ItemAlign;
  public alignContent: FlexAlign = flexContentMapData.get('Default')!.value as FlexAlign;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'elements':
          this.elements =
            attribute.currentValue === ElementsNums.FOUR.toString() ? ElementsNums.FOUR : ElementsNums.TWO;
          break;
        case 'direction':
          this.direction =
            flexDirectionMapData.get(attribute.currentValue)?.value as FlexDirection ?? FlexDirection.Row;
          break;
        case 'wrap':
          this.wrap = flexWrapMapData.get(attribute.currentValue)?.value as FlexWrap ?? FlexWrap.NoWrap;
          break;
        case 'justifyContent':
          this.justifyContent =
            flexContentMapData.get(attribute.currentValue)?.value as FlexAlign ?? FlexAlign.Start;
          break;
        case 'alignItems':
          this.alignItems =
            flexAlignItemMapData.get(attribute.currentValue)?.value as ItemAlign ?? ItemAlign.Auto;
          break;
        case 'alignSelf':
          this.alignSelf = flexAlignItemMapData.get(attribute.currentValue)?.value as ItemAlign ?? ItemAlign.Auto;
          break;
        case 'alignContent':
          this.alignContent =
            flexContentMapData.get(attribute.currentValue)?.value as FlexAlign ?? FlexAlign.Start;
          break;
        default:
          break;
      }
    });
  }
}