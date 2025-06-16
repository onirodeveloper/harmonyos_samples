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
import { placementMapData, PopupStyle, popupStyleCodeMapData, popupStyleMapData } from '../entity/PopupMapping';

export class PopupCodeGenerator implements CommonCodeGenerator {
  private placement: string = placementMapData.get('Default')!.code;
  private type: PopupStyle = popupStyleMapData.get('Default')!;
  private styleCode: string = popupStyleCodeMapData.get(this.type)!;

  public generate(_attributes: OriginAttribute[]): string {
    let width: string = '';
    _attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'placement':
          this.placement = placementMapData.get(attribute.currentValue)?.code ?? this.placement;
          break;
        case 'type':
          this.type = popupStyleMapData.get(attribute.currentValue) ?? this.type;
          this.styleCode = popupStyleCodeMapData.get(this.type) ?? this.styleCode;
          if (this.type !== PopupStyle.STYLE_TEXT) {
            width = `
          width: '300vp',`;
          }
          break;
        default:
          break;
      }
    });
    return `import { Popup } from '@kit.ArkUI';

@Component
struct PopupComponent {
  @State handlePopup: boolean = false;

  @Builder
  popupWithButtonBuilder() {
    Row() {
      ${this.styleCode}
    }
  }

  build() {
    Column() {
      Button('点击弹出气泡')
        .backgroundColor($r('sys.color.background_secondary'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          this.handlePopup = true;
        })
        .bindPopup(this.handlePopup, {
          builder: this.popupWithButtonBuilder(),
          placement: ${this.placement},${width}
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.handlePopup = false;
            }
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}`;
  }
}