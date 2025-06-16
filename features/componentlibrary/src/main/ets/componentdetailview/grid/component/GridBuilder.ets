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

import { Popup } from '@kit.ArkUI';
import { PreferenceManager } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { CommonStorageKey } from '../../common/entity/CommonStorageKey';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { GridAttributeModifier } from '../viewmodel/GridAttributeModifier';
import type { GridDescriptor } from '../viewmodel/GridDescriptor';
import { pixelMapBuilder } from './PixelMapBuilder';
import { getData, ItemData } from '../entity/GridAttributeMapping';

@Builder
export function GridBuilder($$: DescriptorWrapper) {
  GridComponent({ preView: $$.descriptor as GridDescriptor });
}

const DRAG_RATIO: number = 1.1;

@Component
struct GridComponent {
  @State listData: string[] = [];
  @State showPopup: boolean = true;
  @State itemData: ItemData = new ItemData();
  @Prop preView: GridDescriptor;

  aboutToAppear(): void {
    PreferenceManager.getInstance().getValue<boolean>(CommonStorageKey.KEY_GRID_TIP).then((value) => {
      this.showPopup = value ?? true;
    });
    this.listData = getData();
  }

  @Builder
  MyPopup() {
    Row() {
      Popup({
        title: {
          text: $r('app.string.edit'),
        },
        message: {
          text: $r('app.string.editTip')
        },
        showClose: true,
        onClose: () => {
          this.showPopup = false;
        },
        buttons: [
          {
            text: $r('app.string.confirmTip'),
            action: () => {
              this.showPopup = false;
            },
          },
          {
            text: $r('app.string.cancelTip'),
            action: () => {
              PreferenceManager.getInstance().setValue(CommonStorageKey.KEY_GRID_TIP, false);
              this.showPopup = false;
            },
          },
        ],
      })
    }
    .onKeyPreIme((keyEvent: KeyEvent) => {
      if ((keyEvent?.keyText === 'KEYCODE_DPAD_RIGHT' || keyEvent?.keyText === 'KEYCODE_DPAD_LEFT') &&
        keyEvent.type === KeyType.Down) {
        return true;
      }
      return false;
    })
  }

  build() {
    Column() {
      Grid((this.preView as GridDescriptor).scroller) {
        ForEach(this.listData, (item: string, index: number) => {
          GridItem() {
            Text(item)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.icon_emphasize'))
              .textAlign(TextAlign.Center)
              .margin({ right: $r('sys.float.padding_level2') })
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onAreaChange((_oldValue: Area, newValue: Area) => {
            this.itemData.width = (newValue.width as number) * DRAG_RATIO;
            this.itemData.height = (newValue.height as number) * DRAG_RATIO;
          })
          .borderRadius($r('sys.float.corner_radius_level4'))
          .border({ width: $r('app.float.border_width_large'), color: $r('sys.color.comp_background_emphasize') })
          .bindPopup(this.showPopup && index === 0, {
            builder: this.MyPopup(),
            width: $r('app.float.water_flow_width'),
            backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
            radius: ($r('sys.float.corner_radius_level4')),
            mask: false,
            focusable: true,
            popupColor: $r('sys.color.ohos_id_blur_style_component_regular_color'),
            offset: { y: DetailPageConstant.GRID_POPUP_OFFSET_Y },
            placement: Placement.Bottom
          })
        }, (item: string) => item)
      }
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
      .attributeModifier(new GridAttributeModifier(this.preView as GridDescriptor))
    }
    .height('100%')
    .width('100%')
    .padding($r('sys.float.padding_level3'))
    .align(Alignment.Center)
  }
}