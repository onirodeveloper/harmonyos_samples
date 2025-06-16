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

import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { WaterFlowAttributeModifier } from '../viewmodel/WaterFlowAttributeModifier';
import { WaterFlowDescriptor } from '../viewmodel/WaterFlowDescriptor';

const ITEMS_COUNT: number = 20;
const FLOW_ITEMS_COUNT: number = 100;
const THRESHOLD_ITEMS_COUNT: number = 20;

export class WaterFlowDataSource implements IDataSource {
  private dataArray: number[] = [];
  private listeners: DataChangeListener[] = [];

  constructor() {
    for (let i = 0; i < ITEMS_COUNT; i++) {
      this.dataArray.push(i);
    }
  }

  public getData(index: number): number {
    return this.dataArray[index];
  }

  public notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  public notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  public notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  public notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  public notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  public add1stItem(): void {
    this.dataArray.splice(0, 0, this.dataArray.length);
    this.notifyDataAdd(0);
  }

  public addLastItem(): void {
    this.dataArray.splice(this.dataArray.length, 0, this.dataArray.length);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public addItem(index: number): void {
    this.dataArray.splice(index, 0, this.dataArray.length);
    this.notifyDataAdd(index);
  }

  public delete1stItem(): void {
    this.dataArray.splice(0, 1);
    this.notifyDataDelete(0);
  }

  public delete2ndItem(): void {
    this.dataArray.splice(1, 1);
    this.notifyDataDelete(1);
  }

  public deleteLastItem(): void {
    this.dataArray.splice(-1, 1);
    this.notifyDataDelete(this.dataArray.length);
  }

  public reload(): void {
    this.dataArray.splice(1, 1);
    this.dataArray.splice(3, 2);
    this.notifyDataReload();
  }
}

@Builder
export function WaterFlowBuilder($$: DescriptorWrapper) {
  WaterFlowComponent({ waterFlowDescriptor: $$.descriptor as WaterFlowDescriptor })
}

@Component
export struct WaterFlowComponent {
  @Prop waterFlowDescriptor: WaterFlowDescriptor;
  private list: WaterFlowDataSource = new WaterFlowDataSource();
  private minSize: number = DetailPageConstant.WATER_FLOW_MIN_SIZE;
  private maxSize: number = DetailPageConstant.WATER_FLOW_MAX_SIZE;
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];

  getSize() {
    const ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray() {
    for (let i = 0; i < FLOW_ITEMS_COUNT; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear() {
    this.setItemSizeArray();
  }

  build() {
    WaterFlow() {
      LazyForEach(this.list, (item: number) => {
        FlowItem() {
          ReusableFlowItem({ item: item })
        }
        .onAppear(() => {
          if (item + THRESHOLD_ITEMS_COUNT === this.list.totalCount()) {
            for (let i = 0; i < FLOW_ITEMS_COUNT; i++) {
              this.list.addLastItem();
            }
          }
        })
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .border({ radius: $r('sys.float.corner_radius_level4') })
        .width(this.waterFlowDescriptor.layoutDirection === FlexDirection.Column ||
                 this.waterFlowDescriptor.layoutDirection === FlexDirection.ColumnReverse ? '100%' :
               this.itemWidthArray[item % FLOW_ITEMS_COUNT])
        .height(this.waterFlowDescriptor.layoutDirection === FlexDirection.Column ||
                  this.waterFlowDescriptor.layoutDirection === FlexDirection.ColumnReverse ?
                this.itemHeightArray[item % FLOW_ITEMS_COUNT] : '100%')
      }, (item: string, _index: number) => item.toString())
    }
    .cachedCount(2)
    .attributeModifier(new WaterFlowAttributeModifier(this.waterFlowDescriptor))
    .width($r('app.float.water_flow_width'))
    .height($r('app.float.water_flow_height'))
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
}

@Reusable
@Component
struct ReusableFlowItem {
  @State item: number = 0;

  build() {
    Text(`${this.item + 1}`)
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_on_primary'))
  }
}