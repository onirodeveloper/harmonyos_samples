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
import { indicatorEffectMapping, indicatorStyleMapData } from '../entity/SwiperAttributeMapping';

export class SwiperCodeGenerator implements CommonCodeGenerator {
  private isDisplayArrow: boolean = true;
  private displayArrow: string = '';
  private indicatorType: string = 'DotIndicator';
  private indicatorCode: string = indicatorStyleMapData.get('Default')!.code;
  private isVertical: boolean = true;
  private effectMode: string = indicatorEffectMapping.get('Default')!.code;
  private loop: boolean = true;

  public generate(attributes: OriginAttribute[]): string {
    let code = `Swiper() {
      ForEach(this.list, (item: string,index: number) => {
        Text(item.toString())
          .width('90%')
          .height("80%")
          .height(160)
          .backgroundColor(0xAFEEEE)
          .textAlign(TextAlign.Center)
          .fontSize(30)
      }, (item: string) => item)
    }
    .loop(${this.loop})\n`;

    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'indicator':
          this.indicatorType = attribute.currentValue as string;
          this.indicatorCode = `    .indicator(${indicatorStyleMapData.get(this.indicatorType)?.code})`;
          break;
        case 'vertical':
          this.isVertical = JSON.parse(attribute.currentValue);
          code += `    .vertical(${this.isVertical ? 'true' : 'false'})\n`;
          break;
        case 'effectMode':
          this.effectMode = attribute.currentValue as string;
          if (this.effectMode === 'Spring') {
            code += `    .effectMode(EdgeEffect.Spring)`;
          } else if (this.effectMode === 'Fade') {
            code += `    .effectMode(EdgeEffect.Fade)`;
          } else if (this.effectMode === 'None') {
            code += `    .effectMode(EdgeEffect.None)`;
          }
          break;
        case 'isDisplayArrow':
          this.isDisplayArrow = JSON.parse(attribute.currentValue);
          if (this.isDisplayArrow) {
            this.displayArrow = `  .displayArrow({
  showBackground: true,
  isSidebarMiddle: true,
  backgroundSize: 24,
  backgroundColor: Color.White,
  arrowSize: 18,
  arrowColor: Color.Blue
})\n`;
          } else {
            this.displayArrow = '    .displayArrow(false)';
          }
          break;
        case 'loop':
          this.loop = JSON.parse(attribute.currentValue);
          break;
        default:
          break;
      }
    });
    return `function getSwiperData(): number[] {
  const list: number[] = [];
  for (let i = 1; i <= 3; i++) {
    list.push(i);
  }
  return list;
}

@Component
struct SwiperComponent {
  @State list: number[] = getSwiperData();

  build() {
    ${code}\n${this.indicatorCode}\n${this.displayArrow}
  }
}`;
  }
}