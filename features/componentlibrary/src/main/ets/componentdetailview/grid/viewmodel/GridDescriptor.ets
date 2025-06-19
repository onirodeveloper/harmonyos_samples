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
  operationModeMapData,
  rowsGapMapData,
  rowsTemplateMapData,
  scrollerMapData,
} from '../entity/GridAttributeMapping';

@Observed
export class GridDescriptor extends CommonDescriptor {
  public scroller: Scroller = scrollerMapData.get('default')!.value;
  public columnsGap: number = columnsGapMapData.get('default')!.value;
  public rowsGap: number = rowsGapMapData.get('default')!.value;
  public columnsTemplate: string = columnsTemplateMapData.get('default')!.value;
  public rowsTemplate: string = rowsTemplateMapData.get('default')!.value;
  public operationMode: boolean = operationModeMapData.get('default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'columnsGap':
          this.columnsGap = Number(attribute.currentValue);
          break;
        case 'rowsGap':
          this.rowsGap = Number(attribute.currentValue);
          break;
        case 'columnsNum':
          this.columnsTemplate = StringUtil.getTemplateString(Number(attribute.currentValue));
          break;
        case 'rowsNum':
          this.rowsTemplate = StringUtil.getTemplateString(Number(attribute.currentValue));
          break;
        case 'operationMode':
          this.operationMode = JSON.parse(attribute.currentValue);
          break;
        default:
          break;
      }
    });
  }
}