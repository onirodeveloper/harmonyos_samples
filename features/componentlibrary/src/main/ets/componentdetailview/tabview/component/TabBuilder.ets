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

import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import { TabAttributeModifier } from '../viewmodel/TabAttributeModifier';
import type { TabDescriptor } from '../viewmodel/TabDescriptor';

@Builder
export function TabBuilder($$: DescriptorWrapper) {
  TabComponent({ preview: $$.descriptor as TabDescriptor })
}

@Component
struct TabComponent {
  @Prop preview: TabDescriptor;
  @State currentIndex: number = 0;

  @Builder
  tabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r('sys.color.font_emphasize') : $r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Caption_M'))
    }
    .width($r('app.float.tab_bar_width'))
    .height($r('app.float.tab_bar_height'))
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  contentBuilder(text: string) {
    Column() {
      if (text === 'circle') {
        Circle()
          .size({ width: $r('app.float.one_hundred_size'), height: $r('app.float.one_hundred_size') })
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'square') {
        Rect()
          .size({ width: $r('app.float.one_hundred_size'), height: $r('app.float.one_hundred_size') })
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'triangle') {
        Polygon()
          .size({ width: $r('app.float.one_hundred_size'), height: $r('app.float.one_hundred_size') })
          .points([[0, 100], [50, 0], [100, 100]])
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'rectangle') {
        Rect()
          .size({ width: $r('app.float.one_hundred_twenty_size'), height: $r('app.float.eighty_size') })
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'elliptical') {
        Ellipse()
          .size({ width: $r('app.float.one_hundred_size'), height: $r('app.float.eighty_size') })
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'trapezium') {
        Polygon()
          .size({ width: $r('app.float.one_hundred_twenty_size'), height: $r('app.float.eighty_size') })
          .points([[0, 80], [20, 0], [100, 0], [120, 80]])
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'lozenge') {
        Polygon()
          .size({ width: $r('app.float.one_hundred_size'), height: $r('app.float.one_hundred_size') })
          .points([[0, 50], [50, 0], [100, 50], [50, 100]])
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'hexagon') {
        Polygon()
          .size({ width: $r('app.float.one_hundred_size'), height: $r('app.float.one_hundred_size') })
          .points([[50, 0], [93.3, 25], [93.3, 75], [50, 100], [6.7, 75], [6.7, 25]])
          .fill($r('sys.color.icon_emphasize'))
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level4'))
  }

  build() {
    Column() {
      Tabs({ controller: this.preview.controller, barPosition: this.preview.barPosition }) {
        TabContent() {
          this.contentBuilder('circle')
        }.tabBar(this.tabBuilder($r('app.string.circle'), 0))

        TabContent() {
          this.contentBuilder('square')
        }.tabBar(this.tabBuilder($r('app.string.square'), 1))

        TabContent() {
          this.contentBuilder('triangle')
        }.tabBar(this.tabBuilder($r('app.string.triangle'), 2))

        TabContent() {
          this.contentBuilder('rectangle')
        }.tabBar(this.tabBuilder($r('app.string.rectangle'), 3))

        TabContent() {
          this.contentBuilder('elliptical')
        }.tabBar(this.tabBuilder($r('app.string.elliptical'), 4))

        TabContent() {
          this.contentBuilder('trapezium')
        }.tabBar(this.tabBuilder($r('app.string.trapezium'), 5))

        TabContent() {
          this.contentBuilder('lozenge')
        }.tabBar(this.tabBuilder($r('app.string.lozenge'), 6))

        TabContent() {
          this.contentBuilder('hexagon')
        }.tabBar(this.tabBuilder($r('app.string.hexagon'), 7))
      }
      .attributeModifier(new TabAttributeModifier(this.preview))
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .barMode(BarMode.Scrollable)
      .divider({ strokeWidth: '1px', color: $r('sys.color.comp_divider') })
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .padding($r('sys.float.padding_level8'))
    .justifyContent(FlexAlign.Center)
    .backgroundImage($r('app.media.image_background'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .height('100%')
    .width('100%')
  }
}