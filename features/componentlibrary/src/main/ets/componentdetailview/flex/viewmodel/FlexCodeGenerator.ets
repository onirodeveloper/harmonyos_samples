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
  ElementsNums,
  flexAlignItemMapData,
  flexContentMapData,
  flexDirectionMapData,
  flexWrapMapData,
} from '../entity/FlexAttributeMapping';

export class FlexCodeGenerator implements CommonCodeGenerator {
  private direction: string = flexDirectionMapData.get('Default')!.code;
  private wrap: string = flexWrapMapData.get('Default')!.code;
  private justifyContent: string = flexContentMapData.get('Default')!.code;
  private alignItems: string = flexAlignItemMapData.get('Default')!.code;
  private alignSelf: string = flexAlignItemMapData.get('Default')!.code;
  private alignContent: string = flexContentMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    let codeFragment = '';
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'elements':
          codeFragment = attribute.currentValue === ElementsNums.FOUR ? `
      Text('3')
        .width('64vp')
        .height('64vp')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .textAlign(TextAlign.Center)
        .border({ radius: $r('sys.float.corner_radius_level4') })
      Text('4')
        .width('76vp')
        .height('76vp')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .textAlign(TextAlign.Center)
        .border({ radius: $r('sys.float.corner_radius_level4') })` : ``;
          break;
        case 'direction':
          this.direction =
            flexDirectionMapData.get(attribute.currentValue)?.code ?? flexDirectionMapData.get('Default')!.code;
          break;
        case 'wrap':
          this.wrap = flexWrapMapData.get(attribute.currentValue)?.code ?? flexWrapMapData.get('Default')!.code;
          break;
        case 'justifyContent':
          this.justifyContent =
            flexContentMapData.get(attribute.currentValue)?.code ?? flexContentMapData.get('Default')!.code;
          break;
        case 'alignItems':
          this.alignItems =
            flexAlignItemMapData.get(attribute.currentValue)?.code ?? flexAlignItemMapData.get('Default')!.code;
          break;
        case 'alignContent':
          this.alignContent =
            flexContentMapData.get(attribute.currentValue)?.code ?? flexContentMapData.get('Default')!.code;
          break;
        case 'alignSelf':
          this.alignSelf =
            flexAlignItemMapData.get(attribute.currentValue)?.code ?? flexAlignItemMapData.get('Default')!.code;
          break;
        default:
          break;
      }
    });
    return `import { LengthMetrics } from '@kit.ArkUI';

@Component
struct FlexComponent {
  build() {
    Flex({
      space: { main: LengthMetrics.vp(6), cross: LengthMetrics.vp(6) },
      direction: ${this.direction},
      wrap: ${this.wrap},
      justifyContent: ${this.justifyContent},
      alignItems: ${this.alignItems},
      alignContent: ${this.alignContent}
    }) {
      Text('1')
        .width('40vp')
        .height('40vp')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .textAlign(TextAlign.Center)
        .border({ radius: $r('sys.float.corner_radius_level4') })
      Text('2')
        .width('52vp')
        .height('52vp')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .textAlign(TextAlign.Center)
        .border({  radius: $r('sys.float.corner_radius_level4') })
        .alignSelf(${this.alignSelf})${codeFragment}
    }
    .height('180vp')
    .width('262vp')
    .padding($r('sys.float.padding_level3'))
    .border({ width: 1, color: $r('sys.color.comp_background_emphasize'), radius: $r('sys.float.corner_radius_level6') })
  }
}`;
  }
}