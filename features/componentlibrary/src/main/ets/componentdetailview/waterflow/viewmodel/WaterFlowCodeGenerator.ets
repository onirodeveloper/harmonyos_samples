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
  frictionMapData,
  layoutDirectionMapData,
  rowsTemplateMapData,
} from '../entity/WaterFlowAttributeMapping';

export class WaterFlowCodeGenerator implements CommonCodeGenerator {
  private layoutDirection: string = layoutDirectionMapData.get('Default')!.code;
  private friction: string = frictionMapData.get('Default')!.code;
  private columnsTemplate: string = columnsTemplateMapData.get('Default')!.code;
  private rowsTemplate: string = rowsTemplateMapData.get('Default')!.code;
  private columnsGap: string = columnsGapMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    let itemWidth = '';
    let itemHeight = '';
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'layoutDirection':
          this.layoutDirection =
            layoutDirectionMapData.get(attribute.currentValue)?.code ?? layoutDirectionMapData.get('Default')!.code;
          if (this.layoutDirection === `FlexDirection.Column` ||
            this.layoutDirection === `FlexDirection.ColumnReverse`) {
            itemWidth = `'100%'`;
            itemHeight = 'this.itemHeightArray[item % 100]';
          } else {
            itemWidth = 'this.itemWidthArray[item % 100]';
            itemHeight = `'100%'`;
          }
          break;
        case 'friction':
          this.friction = frictionMapData.get(attribute.currentValue)?.code ?? frictionMapData.get('Default')!.code;
          break;
        case 'columnsTemplate':
          this.columnsTemplate = StringUtil.getTemplateString(Number(attribute.currentValue));
          break;
        case 'rowsTemplate':
          this.rowsTemplate = StringUtil.getTemplateString(Number(attribute.currentValue));
          break;
        case 'columnsGap':
          this.columnsGap = attribute.currentValue;
          break;
        default:
          break;
      }
    });
    return `export class WaterFlowDataSource implements IDataSource {
  private dataArray: number[] = []
  private listeners: DataChangeListener[] = []

  constructor() {
    for (let i = 0; i < 100; i++) {
      this.dataArray.push(i)
    }
  }

  public getData(index: number): number {
    return this.dataArray[index]
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }

  public totalCount(): number {
    return this.dataArray.length
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  public add1stItem(): void {
    this.dataArray.splice(0, 0, this.dataArray.length)
    this.notifyDataAdd(0)
  }

  public addLastItem(): void {
    this.dataArray.splice(this.dataArray.length, 0, this.dataArray.length)
    this.notifyDataAdd(this.dataArray.length - 1)
  }

  public addItem(index: number): void {
    this.dataArray.splice(index, 0, this.dataArray.length)
    this.notifyDataAdd(index)
  }

  public delete1stItem(): void {
    this.dataArray.splice(0, 1)
    this.notifyDataDelete(0)
  }

  public delete2ndItem(): void {
    this.dataArray.splice(1, 1)
    this.notifyDataDelete(1)
  }

  public deleteLastItem(): void {
    this.dataArray.splice(-1, 1)
    this.notifyDataDelete(this.dataArray.length)
  }

  public reload(): void {
    this.dataArray.splice(1, 1)
    this.dataArray.splice(3, 2)
    this.notifyDataReload()
  }
}

@Reusable
@Component
struct ReusableFlowItem {
  @State item: number = 0;

  build() {
    Text(this.item + 1 + '')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_on_primary'))
  }
}

@Component
export struct WaterFlowComponent {
  private list: WaterFlowDataSource = new WaterFlowDataSource();
  private minSize: number = 92;
  private maxSize: number = 180;
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];

  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray() {
    for (let i = 0; i < 100; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear() {
    this.setItemSizeArray();
  }

  build() {
    Column() {
      WaterFlow() {
        LazyForEach(this.list, (item: number) => {
          FlowItem() {
            ReusableFlowItem({ item: item })
          }
          .onAppear(() => {
            if (item + 20 === this.list.totalCount()) {
              for (let i = 0; i < 100; i++) {
                this.list.addLastItem();
              }
            }
          })
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .border({ radius: $r('sys.float.corner_radius_level4') })
          .width(${itemWidth})
          .height(${itemHeight})

        }, (item: string, _index: number) => item.toString())
      }
      .cachedCount(2)
      .width('300vp')
      .height('200vp')
      .layoutDirection(${this.layoutDirection})
      .friction(${this.friction})
      .columnsTemplate('${this.columnsTemplate}')
      .rowsTemplate('${this.rowsTemplate}')
      .columnsGap(${this.columnsGap})
      .rowsGap($r('sys.float.padding_level3'))
      .padding($r('sys.float.padding_level3'))
      .border({
        width: 1,
        color: $r('sys.color.comp_background_emphasize'),
        radius: $r('sys.float.corner_radius_level6')
      })
      .onScrollFrameBegin((offset: number) => {
        return { offsetRemain: offset };
      })
    }
    .width('100%')
  }
}`;
  }
}