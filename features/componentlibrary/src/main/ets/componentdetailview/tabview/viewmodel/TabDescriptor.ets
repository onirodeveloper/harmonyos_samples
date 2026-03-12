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
import { DEFAULT_KEY } from '../../common/entity/CommonMapData';
import {
  barHeightMapData,
  barPositionMapData,
  barWidthMapData,
  blurStyleMapData,
  fadingEdgeMapData,
  verticalMapData,
} from '../entity/TabAttributeMapping';

@Observed
export class TabDescriptor extends CommonDescriptor {
  public controller: TabsController = new TabsController();
  public barPosition: BarPosition = barPositionMapData.get(DEFAULT_KEY)!.value as BarPosition;
  public vertical: boolean = verticalMapData.get(DEFAULT_KEY)!.value as boolean;
  public barWidth: string = barWidthMapData.get(DEFAULT_KEY)!.value as string;
  public barHeight: string = barHeightMapData.get(DEFAULT_KEY)!.value as string;
  public backgroundBlurStyle: BlurStyle = blurStyleMapData.get(DEFAULT_KEY)!.value as BlurStyle;
  public fadingEdge: boolean = fadingEdgeMapData.get(DEFAULT_KEY)!.value as boolean;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'barPosition':
          this.barPosition = barPositionMapData.get(attribute.currentValue)?.value as BarPosition ??
            barPositionMapData.get(DEFAULT_KEY)!.value as BarPosition;
          break;
        case 'vertical':
          try {
            this.vertical = JSON.parse(attribute.currentValue);
          } catch (_e) {
            this.vertical = verticalMapData.get(DEFAULT_KEY)!.value as boolean;
          }
          if (this.vertical) {
            this.barWidth = '64vp';
            this.barHeight = '100%';
          } else {
            this.barWidth = '100%';
            this.barHeight = '30';
          }
          break;
        case 'backgroundBlurStyle':
          this.backgroundBlurStyle = blurStyleMapData.get(attribute.currentValue)?.value as BlurStyle ??
            blurStyleMapData.get(DEFAULT_KEY)!.value as BlurStyle;
          break;
        case 'fadingEdge':
          this.fadingEdge = JSON.parse(attribute.currentValue) ?? fadingEdgeMapData.get(DEFAULT_KEY)!.value as boolean;
          break;
        default:
          break;
      }
    });
  }
}