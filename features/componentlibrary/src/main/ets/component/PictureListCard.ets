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

import { deviceInfo } from '@kit.BasicServicesKit';
import { ImageComponent, ProductSeriesEnum } from '@ohos/common';
import type { ComponentCardData, ComponentContent } from '../model/ComponentData';
import { ComponentItemList } from './ComponentItemList';

@Reusable
@Component
export struct PictureListCard {
  @State widthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @State componentCardData?: ComponentCardData = undefined;
  @State isVdeSeries: boolean = deviceInfo.productSeries === ProductSeriesEnum.VDE;
  handleItemClick?: (componentContent: ComponentContent) => void;

  aboutToReuse(params: Record<string, Object>): void {
    this.componentCardData = params.componentCardData as ComponentCardData;
    this.widthBreakpoint = params.widthBreakpoint as WidthBreakpoint;
    this.handleItemClick = params.handleItemClick as (componentContent: ComponentContent) => void;
  }

  @Builder
  textOverlay() {
    Column() {
      Text(this.componentCardData?.subTitle)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_on_secondary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('sys.float.padding_level2') })
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(this.componentCardData?.title)
        .fontSize($r('sys.float.Title_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.END)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.End)
    .padding($r('sys.float.padding_level6'))
    .width('100%')
    .height(this.isVdeSeries ? $r('app.float.card_top_height_verde') : $r('app.float.card_top_height'))
    .margin({ bottom: $r('sys.float.padding_level2') })
  }

  build() {
    Column() {
      ImageComponent({
        src: this.componentCardData?.image,
        objectFit: ImageFit.Cover,
      })
        .backgroundColor(this.componentCardData?.themeColor)
        .width('100%')
        .height(this.isVdeSeries ? $r('app.float.card_top_height_verde') : $r('app.float.card_top_height'))
        .overlay(this.textOverlay())
        .margin({ bottom: $r('sys.float.padding_level2') })

      ComponentItemList({
        cardContents: this.componentCardData?.componentContents ?? [],
        widthBreakpoint: this.widthBreakpoint,
        buttonColor: this.componentCardData?.themeColor,
        handleItemClick: (item: ComponentContent) => {
          this.handleItemClick?.(item);
        }
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
    .width('100%')
    .padding({ bottom: $r('sys.float.padding_level2') })
  }
}