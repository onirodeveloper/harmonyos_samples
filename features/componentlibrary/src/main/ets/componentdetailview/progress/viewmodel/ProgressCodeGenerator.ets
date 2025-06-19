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

import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import {
  progressColorMapData,
  progressKindMapData,
  progressStyleMapData,
  progressTypeMapData,
  progressValueMapData,
} from '../entity/ProgressAttributeMapping';

export class ProgressCodeGenerator implements CommonCodeGenerator {
  private value: string = progressValueMapData.get('Default')!.code;
  private color: string = progressColorMapData.get('Default')!.code;
  private type: string = progressTypeMapData.get('Default')!.code;
  private style: string = progressStyleMapData.get('Default')!.code;
  private kind: string = progressKindMapData.get('Default')!.code;
  private height: number = DetailPageConstant.PROGRESS_LINE_HEIGHT;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'value':
          this.value = attribute.currentValue;
          break;
        case 'color':
          this.color = attribute.currentValue;
          break;
        case 'kind':
          this.kind = attribute.currentValue;
          break;
        case 'style':
          this.type = progressTypeMapData.get(attribute.currentValue)?.code ?? this.type;
          this.style = progressStyleMapData.get(attribute.currentValue)?.code ?? this.style;
          this.height = this.type === 'ProgressType.Capsule' ? DetailPageConstant.PROGRESS_CAPSULE_HEIGHT :
          DetailPageConstant.PROGRESS_LINE_HEIGHT;
          break;
        default:
          break;
      }
    });
    let codeStr = '';
    if (this.kind === 'Progress') {
      codeStr = `Progress({ value: ${this.value}, total: 100, type: ${this.type} })
        .color('${this.color}')
        .style(${this.style})
        .height(${this.height})`;
    } else {
      codeStr = `LoadingProgress()
        .color('${this.color}')
        .size({ width: 64, height: 64 })`;
    }
    return `@Component
struct ProgressComponent {
  build() {
    Column() {
      ${codeStr}
    }
    .padding($r('sys.float.padding_level16'))
    .justifyContent(FlexAlign.Center)
  }
}`;
  }
}