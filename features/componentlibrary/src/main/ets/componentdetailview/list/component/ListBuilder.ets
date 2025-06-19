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

import { CommonConstants } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { timeTable, TimeTable } from '../entity/ListAttributeMapping';
import { ListAttributeModifier } from '../viewmodel/ListAttributeModifier';
import type { ListDescriptor } from '../viewmodel/ListDescriptor';
import { itemHead } from './ItemHead';

@Builder
export function ListBuilder($$: DescriptorWrapper) {
  Column() {
    List({ space: DetailPageConstant.SPACE_NORMAL }) {
      ForEach(timeTable, (item: TimeTable) => {
        ListItemGroup({ header: itemHead(item.title, $$), space: CommonConstants.SPACE_8 }) {
          ForEach(item.projects, (project: string) => {
            listItemBuilder(project, $$);
          }, (item: string) => item)
        }
        .height('100%')
        .width('100%')
        .padding({
          left: $r('sys.float.padding_level4'),
          right: $r('sys.float.padding_level4'),
          bottom: $r('sys.float.padding_level2'),
        })
      }, (item: TimeTable, _index: number) => item.title.toString())
    }
    .sticky(($$.descriptor as ListDescriptor).sticky ? StickyStyle.Header : StickyStyle.None)
    .scrollBar(BarState.Off)
    .attributeModifier(new ListAttributeModifier($$.descriptor as ListDescriptor))
    .width('100%')
    .height('100%')
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .width('100%')
  .height('100%')
  .clip(true)
  .borderRadius($r('sys.float.corner_radius_level8'))
}

@Builder
function listItemBuilder(param: string, $$: DescriptorWrapper) {
  ListItem() {
    Column() {
      Text(param)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .borderRadius($r('sys.float.corner_radius_level4'))
    .justifyContent(FlexAlign.Center)
    .border({ width: $r('app.float.border_width_large'), color: $r('sys.color.comp_background_emphasize') })
  }
  .width('100%')
  .height(($$.descriptor as ListDescriptor).lanes.value >= DetailPageConstant.LIST_LANES_THRESHOLD ?
  $r('app.float.component_item_height') : $r('app.float.component_item_height_max'))
  .aspectRatio(($$.descriptor as ListDescriptor).lanes.value >= DetailPageConstant.LIST_LANES_THRESHOLD ?
  DetailPageConstant.ASPECT_RATIO_SQUARE : DetailPageConstant.ASPECT_RATIO_INVALID)
}