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

import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, CommonConstants } from '@ohos/common';
import type { TabBarData } from '../model/TabBarModel';
import { TABS_LIST } from '../model/TabBarModel';

@Component
export struct CustomTabBar {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @StorageProp('BlurRenderGroup') blurRenderGroup: boolean = false;
  @Prop @Require currentIndex: number;
  tabBarChange: (index: number) => void = (index: number) => {
  };

  @Builder
  TabItemBuilder(tabBar: TabBarData) {
    Column() {
      SymbolGlyph(tabBar.icon)
        .fontSize($r('sys.float.Title_M'))
        .fontColor(tabBar.id === this.currentIndex ? [$r('sys.color.interactive_active')] :
          [$r('sys.color.font_tertiary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .symbolEffect(new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.UP), tabBar.id === this.currentIndex)
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
      }).getValue(this.globalInfoModel.currentBreakpoint),
      alignItems: ItemAlign.Center,
    }) {
      Flex({
        direction: new BreakpointType({
          sm: FlexDirection.Row,
          md: FlexDirection.Row,
          lg: FlexDirection.Column,
        }).getValue(this.globalInfoModel.currentBreakpoint),
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceAround,
      }) {
        ForEach(TABS_LIST, (item: TabBarData) => {
          this.TabItemBuilder(item)
        }, (item: TabBarData) => JSON.stringify(item) + this.currentIndex)
      }
      .size(new BreakpointType<SizeOptions>({
        sm: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT },
        md: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT },
        lg: { width: CommonConstants.TAB_BAR_WIDTH, height: '50%' },
      }).getValue(this.globalInfoModel.currentBreakpoint))
      .margin({
        bottom: new BreakpointType({
          sm: this.globalInfoModel.naviIndicatorHeight,
          md: this.globalInfoModel.naviIndicatorHeight,
          lg: 0,
        }).getValue(this.globalInfoModel.currentBreakpoint),
      })

      Divider()
        .vertical(new BreakpointType({
          sm: false,
          md: false,
          lg: true,
        }).getValue(this.globalInfoModel.currentBreakpoint))
        .color($r('sys.color.comp_divider'))
    }
    .size(new BreakpointType<SizeOptions>({
      sm: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight },
      md: { width: '100%', height: CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight },
      lg: { width: CommonConstants.TAB_BAR_WIDTH, height: '100%' },
    }).getValue(this.globalInfoModel.currentBreakpoint))
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .renderGroup(this.blurRenderGroup)
  }
}