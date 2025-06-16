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
import {
  columnsGapMapData,
  columnsTemplateMapData,
  operationModeMapData,
  rowsGapMapData,
  rowsTemplateMapData,
  scrollerMapData,
} from '../entity/GridAttributeMapping';

export class GridCodeGenerator implements CommonCodeGenerator {
  private scroller: string = scrollerMapData.get('default')!.code;
  private columnsGap: string = columnsGapMapData.get('default')!.code;
  private rowsGap: string = rowsGapMapData.get('default')!.code;
  private columnsTemplate: string = columnsTemplateMapData.get('default')!.code;
  private rowsTemplate: string = rowsTemplateMapData.get('default')!.code;
  private operationMode: string = operationModeMapData.get('default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'columnsGap':
          this.columnsGap = attribute.currentValue;
          break;
        case 'rowsGap':
          this.rowsGap = attribute.currentValue;
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

    return `
@Observed
export class ItemData {
  public text: ResourceStr;
  public width: Resource | number;
  public height: Resource | number;

  constructor(text: ResourceStr = '', width: Resource | number = 0, height: Resource | number = 0) {
    this.text = text;
    this.width = width;
    this.height = height;
  }
}

@Builder
export function pixelMapBuilder($$: ItemData) {
  Text($$.text)
    .fontSize($r('sys.float.Body_L'))
    .size({ width: $$.width, height: $$.height })
    .fontColor($r('sys.color.icon_emphasize'))
    .textAlign(TextAlign.Center)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .borderRadius($r('sys.float.corner_radius_level4'))
    .border({ width: 1.5, color: $r('sys.color.comp_background_emphasize') })
}

@Component
struct GridComponent {
  @State listData: string[] = [];
  @State itemData: ItemData = new ItemData();

  aboutToAppear(): void {
    for (let i = 1; i <= 30; i++) {
      this.listData.push('item' + i);
    }
  }

  build() {
    Column() {
      Grid(${this.scroller}) {
        ForEach(this.listData, (item: string) => {
          GridItem() {
            Text(item)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.icon_emphasize'))
              .textAlign(TextAlign.Center)
              .margin({ right: $r('sys.float.padding_level2') })
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.itemData.width = (newValue.width as number) * 1.1;
            this.itemData.height = (newValue.height as number) * 1.1;
          })
          .borderRadius($r('sys.float.corner_radius_level4'))
          .border({ width: 1.5, color: $r('sys.color.comp_background_emphasize') })
        }, (item: string) => item)
      }
      .editMode(${this.operationMode})
      .onItemDragStart((_event: ItemDragInfo, itemIndex: number) => {
        this.itemData.text = this.listData[itemIndex];
        return pixelMapBuilder(this.itemData);
      })
      .onItemDrop((_event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean): void => {
        if (!isSuccess || insertIndex >= this.listData.length) {
          return;
        }
        const temp: string = this.listData[itemIndex];
        this.listData[itemIndex] = this.listData[insertIndex];
        this.listData[insertIndex] = temp;
      })
      .columnsGap(${this.columnsGap})
      .rowsGap(${this.rowsGap})
      .rowsTemplate('${this.rowsTemplate}')
      .columnsTemplate('${this.columnsTemplate}')
    }
    .height('100%')
    .width('100%')
    .padding($r('sys.float.padding_level3'))
    .align(Alignment.Center)
  }
}`;
  }
}