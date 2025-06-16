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
import {
  columnsGapMapData,
  columnsTemplateMapData,
  frictionMapData,
  layoutDirectionMapData,
  rowsTemplateMapData,
} from '../entity/WaterFlowAttributeMapping';

@Observed
export class WaterFlowDescriptor extends CommonDescriptor {
  public layoutDirection: FlexDirection = layoutDirectionMapData.get('Default')!.value as FlexDirection;
  public friction: number = frictionMapData.get('Default')!.value as number;
  public columnsTemplate: string = columnsTemplateMapData.get('Default')!.value as string;
  public rowsTemplate: string = rowsTemplateMapData.get('Default')!.value as string;
  public columnsGap: number = columnsGapMapData.get('Default')!.value as number;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'layoutDirection':
          this.layoutDirection = layoutDirectionMapData.get(attribute.currentValue)?.value as FlexDirection ??
            layoutDirectionMapData.get('Default')!.value as FlexDirection;
          break;
        case 'friction':
          this.friction =
            frictionMapData.get(attribute.currentValue)?.value as number ??
              frictionMapData.get('Default')!.value as number;
          break;
        case 'columnsTemplate':
          this.columnsTemplate =
            StringUtil.getTemplateString(Number(attribute.currentValue)) ??
              columnsTemplateMapData.get('Default')!.value as string;
          break;
        case 'rowsTemplate':
          this.rowsTemplate =
            StringUtil.getTemplateString(Number(attribute.currentValue)) ?? rowsTemplateMapData.get('Default')!.value as string;
          break;
        case 'columnsGap':
          this.columnsGap = Number(attribute.currentValue) ?? columnsGapMapData.get('Default')!.value as number;
          break;
        default:
          break;
      }
    });
  }
}