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

import { BreakpointType, CommonConstants, GlobalInfoModel, StorageKey } from '@ohos/common';
import type { ComponentCardData, ComponentContent } from '../model/ComponentData';
import { ComponentItemList } from './ComponentItemList';

@Reusable
@Component
export struct ListCard {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State componentCardData?: ComponentCardData = undefined;
  handleItemClick?: (componentContent: ComponentContent) => void;

  aboutToReuse(params: Record<string, Object>): void {
    this.componentCardData = params.componentCardData as ComponentCardData;
    this.handleItemClick = params.handleItemClick as (componentContent: ComponentContent) => void;
  }

  build() {
    Column() {
      Column() {
        Text(this.componentCardData?.subTitle)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({
            left: $r('sys.float.padding_level8'),
            bottom: $r('sys.float.padding_level2'),
          })
          .maxLines(1)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.componentCardData?.title)
          .fontSize($r('sys.float.Title_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({
            left: $r('sys.float.padding_level8'),
            bottom: $r('sys.float.padding_level4'),
          })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .height(CommonConstants.NAVIGATION_HEIGHT)

      ComponentItemList({
        buttonColor: this.componentCardData?.themeColor,
        cardContents: this.componentCardData?.componentContents ?? [],
        widthBreakpoint: this.globalInfoModel.widthBreakpoint,
        handleItemClick: (item: ComponentContent) => {
          this.handleItemClick?.(item);
        }
      })
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .border({
      width: $r('sys.float.border_none'),
      color: $r('sys.color.comp_background_list_card'),
      radius: $r('sys.float.corner_radius_level8'),
    })
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .alignItems(HorizontalAlign.Start)
    .clip(true)
    .padding({
      top: $r('sys.float.padding_level8'),
      bottom: new BreakpointType({
        sm: $r('sys.float.padding_level2'),
        md: $r('sys.float.padding_level4'),
        lg: $r('sys.float.padding_level4')
      }).getValue(this.globalInfoModel.widthBreakpoint),
    })
  }
}