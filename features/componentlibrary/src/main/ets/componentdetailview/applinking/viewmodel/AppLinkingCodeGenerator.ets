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

import { ConfigMapKey, ResourceUtil } from '@ohos/common';
import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import {
  LinkType,
  typeImportCodeMapData,
  typeInvokeCodeMapData,
  typeMapData,
} from '../entity/AppLinkingAttributeMapping';

export class AppLinkingCodeGenerator implements CommonCodeGenerator {
  private type: LinkType = typeMapData.get('Default')!;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'type':
          this.type = typeMapData.get(attribute.currentValue) ?? this.type;
          break;
        default:
          break;
      }
    });
    let codeStr: string = typeInvokeCodeMapData.get(this.type)!;
    if (this.type === LinkType.TYPE_GALLERY) {
      const linkUrl: string = ResourceUtil.getRawFileStringByKey(getContext(), ConfigMapKey.GALLERY_URL);
      codeStr = codeStr.replace('%s', linkUrl);
    }
    return `${typeImportCodeMapData.get(this.type)!}

@Component
struct AppLinkingComponent {
  build() {
    Column() {
      Button('拉起${this.type}页')
        .backgroundColor($r('sys.color.background_secondary'))
        .height(40)
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          ${codeStr}
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}`;
  }
}