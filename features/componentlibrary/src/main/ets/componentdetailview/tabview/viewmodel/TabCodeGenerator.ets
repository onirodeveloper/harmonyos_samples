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

import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import {
  barHeightMapData,
  barPositionMapData,
  barWidthMapData,
  blurStyleMapData,
  fadingEdgeMapData,
  verticalMapData,
} from '../entity/TabAttributeMapping';

export class TabCodeGenerator implements CommonCodeGenerator {
  private barPosition: string = barPositionMapData.get('Default')!.code;
  private vertical: string = verticalMapData.get('Default')!.code;
  private barWidth: string = barWidthMapData.get('Default')!.code;
  private barHeight: string = barHeightMapData.get('Default')!.code;
  private backgroundBlurStyle: string = blurStyleMapData.get('Default')!.code;
  private fadingEdge: string = fadingEdgeMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'barPosition':
          this.barPosition =
            barPositionMapData.get(attribute.currentValue)?.code ?? barPositionMapData.get('Default')!.code;
          break;
        case 'vertical':
          this.vertical = attribute.currentValue;
          if (this.vertical === 'true') {
            this.barWidth = '64vp';
            this.barHeight = '100%';
          } else {
            this.barWidth = '100%';
            this.barHeight = '30vp';
          }
          break;
        case 'backgroundBlurStyle':
          this.backgroundBlurStyle =
            blurStyleMapData.get(attribute.currentValue)?.code ?? blurStyleMapData.get('Default')!.code;
          break;
        case 'fadingEdge':
          this.fadingEdge = attribute.currentValue;
          break;
        default:
          break;
      }
    });
    return `@Component
struct TabComponent {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();

  @Builder
  tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r('sys.color.font_emphasize') : $r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Caption_M'))
    }
    .width(72)
    .height(30)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  contentBuilder(text: string) {
    Column() {
      if (text === 'circle') {
        Circle().size({ width: 100, height: 100 }).fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'square') {
        Rect().size({ width: 100, height: 100 }).fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'triangle') {
        Polygon({ width: 100, height: 100 })
          .points([[0, 100], [50, 0], [100, 100]])
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'rectangle') {
        Rect().size({ width: 120, height: 80 }).fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'elliptical') {
        Ellipse().size({ width: 100, height: 80 }).fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'trapezium') {
        Polygon({ width: 120, height: 80 })
          .points([[0, 80], [20, 0], [100, 0], [120, 80]])
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'lozenge') {
        Polygon({ width: 100, height: 100 })
          .points([[0, 50], [50, 0], [100, 50], [50, 100]])
          .fill($r('sys.color.icon_emphasize'))
      }
      if (text === 'hexagon') {
        Polygon({ width: 100, height: 100 })
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
      Tabs({ controller: this.controller }) {
        TabContent() {
          this.contentBuilder('circle')
        }.tabBar(this.tabBuilder('圆形', 0))

        TabContent() {
          this.contentBuilder('square')
        }.tabBar(this.tabBuilder('正方形', 1))

        TabContent() {
          this.contentBuilder('triangle')
        }.tabBar(this.tabBuilder('三角形', 2))

        TabContent() {
          this.contentBuilder('rectangle')
        }.tabBar(this.tabBuilder('长方形', 3))

        TabContent() {
          this.contentBuilder('elliptical')
        }.tabBar(this.tabBuilder('椭圆', 4))

        TabContent() {
          this.contentBuilder('trapezium')
        }.tabBar(this.tabBuilder('梯形', 5))

        TabContent() {
          this.contentBuilder('lozenge')
        }.tabBar(this.tabBuilder('菱形', 6))

        TabContent() {
          this.contentBuilder('hexagon')
        }.tabBar(this.tabBuilder('六边形', 7))
      }
      .barWidth('${this.barWidth}')
      .barHeight('${this.barHeight}')
      .vertical(${this.vertical})
      .barPosition(${this.barPosition})
      .backgroundBlurStyle(${this.backgroundBlurStyle})
      .fadingEdge(${this.fadingEdge})
      .barMode(BarMode.Scrollable)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .divider({ strokeWidth: '1px', color: $r('sys.color.comp_divider') })
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .padding($r('sys.float.padding_level8'))
    .justifyContent(FlexAlign.Center)
    .backgroundImage($r('app.media.image_background')) // 替换自己项目图片资源文件
    .backgroundImageSize({ width: '100%', height: '100%' })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .height('100%')
    .width('100%')
  }
}`;
  }
}