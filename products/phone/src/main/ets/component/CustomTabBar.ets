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
import type { TabBarData } from '../model/TabBarModel';
import { TABS_LIST } from '../model/TabBarModel';

@Component
export struct CustomTabBar {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.BLUE_RENDER_GROUP) blurRenderGroup: boolean = false;
  @Prop @Require currentIndex: number;
  @State symbolEffect: BounceSymbolEffect = new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.UP);
  tabBarChange: (index: number) => void = (_index: number) => {
  };

  @Builder
  TabItemBuilder(tabBar: TabBarData) {
    Column() {
      SymbolGlyph(tabBar.icon)
        .fontSize($r('sys.float.Title_M'))
        .fontColor(tabBar.id === this.currentIndex ? [$r('sys.color.interactive_active')] :
          [$r('sys.color.font_tertiary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .symbolEffect(this.symbolEffect, tabBar.id === this.currentIndex)
      Text(tabBar.title)
        .fontSize($r('sys.float.Caption_M'))
        .margin({ top: $r('sys.float.padding_level1') })
        .fontWeight(FontWeight.Medium)
        .fontColor(tabBar.id === this.currentIndex ? $r('sys.color.interactive_active') : $r('sys.color.font_tertiary'))
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      if (this.currentIndex !== tabBar.id) {
        this.tabBarChange(tabBar.id);
      }
    })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Flex({
      direction: new BreakpointType({
        sm: FlexDirection.ColumnReverse,
        md: FlexDirection.ColumnReverse,
        lg: FlexDirection.Row,
      }).getValue(this.globalInfoModel.widthBreakpoint),
      alignItems: ItemAlign.Center,
    }) {
      Flex({
        direction: new BreakpointType({
          sm: FlexDirection.Row,
          md: FlexDirection.Row,
          lg: FlexDirection.Column,
        }).getValue(this.globalInfoModel.widthBreakpoint),
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceAround,
      }) {
        ForEach(TABS_LIST, (item: TabBarData) => {
          this.TabItemBuilder(item)
        }, (item: TabBarData, index: number) => item.id.toString() + (this.currentIndex === index))
      }
      .size(new BreakpointType<SizeOptions>({
        sm: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT },
        md: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT },
        lg: { width: CommonConstants.TAB_BAR_WIDTH, height: '50%' },
      }).getValue(this.globalInfoModel.widthBreakpoint))
      .margin({
        bottom: new BreakpointType({
          sm: this.globalInfoModel.naviIndicatorHeight,
          md: this.globalInfoModel.naviIndicatorHeight,
          lg: 0,
        }).getValue(this.globalInfoModel.widthBreakpoint),
      })

      Divider()
        .vertical(new BreakpointType({
          sm: false,
          md: false,
          lg: true,
        }).getValue(this.globalInfoModel.widthBreakpoint))
        .color($r('sys.color.comp_divider'))
    }
    .size(new BreakpointType<SizeOptions>({
      sm: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight },
      md: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight },
      lg: { width: CommonConstants.TAB_BAR_WIDTH, height: '100%' },
    }).getValue(this.globalInfoModel.widthBreakpoint))
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .renderGroup(this.blurRenderGroup)
  }
}