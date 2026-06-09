/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { ColorUtil, CommonConstants } from '@ohos/common';
import { BarItemData } from '../model/BarItemData';
import { BarItem } from './BarItem';

const TAG: string = '[BarComponent]';

@Component
export struct BarComponent {
  barItemDataList?: BarItemData[];
  @Link currentIndex: number;

  build() {
    Column() {
      RelativeContainer() {
        Row() {
          ForEach(this.barItemDataList, (barItemData: BarItemData, index: number) => {
            BarItem({ barItemData: barItemData, currentIndex: this.currentIndex, index: index })
          })
        }
        .borderRadius($r('app.float.bar_component_border_radius'))
        .borderColor($r('app.color.bar_item_border_color'))
        .backgroundColor(ColorUtil.getBlendColor(TAG, $r('app.color.bar_component_blend_background'),
          $r('app.color.bar_component_blend_foreground')))
      }
      .width(CommonConstants.AUTO_FIT)
    }
    .height($r('app.float.bar_component_height'))
  }
}

