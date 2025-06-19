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
  actionSheetInfoMapData,
  autoCancelMapData,
  transitionAppearMapData,
  transitionDisAppearMapData,
  transitionMapData,
} from '../entity/ActionSheetAttributeMapping';

export class ActionSheetCodeGenerator implements CommonCodeGenerator {
  private autoCancel: string = autoCancelMapData.get('Default')!.code;
  private transition: string = transitionMapData.get('Default')!.code;
  private sheetInfo: string = actionSheetInfoMapData.get('Default')!.code;
  private transitionAppear: string = transitionAppearMapData.get('Default')!.code;
  private transitionDisappear: string = transitionDisAppearMapData.get('Default')!.code;

  public generate(attributes: OriginAttribute[]): string {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'autoCancel':
          this.autoCancel = attribute.currentValue;
          break;
        case 'transition':
          this.transition = attribute.currentValue;
          if (this.transition === 'true') {
            this.transitionAppear = transitionAppearMapData.get('Default')!.code;
            this.transitionDisappear = transitionDisAppearMapData.get('Default')!.code;
          } else {
            this.transitionAppear = 'undefined';
            this.transitionDisappear = 'undefined';
          }
          break;
        case 'sheetInfo':
          this.sheetInfo = actionSheetInfoMapData.get(attribute.currentValue)?.code ?? this.sheetInfo;
          break;
        default:
          break;
      }
    });
    return `import { promptAction } from '@kit.ArkUI';

@Component
struct ActionSheetComponent {
  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Button('列表选择器弹窗', { buttonStyle: ButtonStyleMode.NORMAL })
        .buttonStyle(ButtonStyleMode.NORMAL)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          ActionSheet.show({
            title: '标题',
            subtitle: '副标题',
            message: '内容',
            autoCancel: ${this.autoCancel},
            transition: TransitionEffect.asymmetric(
              ${this.transitionAppear},
              ${this.transitionDisappear}
            ),
            confirm: {
              defaultFocus: true,
              value: '确定',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'confirm is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              }
            },
            alignment: DialogAlignment.Center,
            offset: { dx: 0, dy: -10 },
            sheets: ${this.sheetInfo}
          });
        })
    }
    .width('100%')
    .height('100%')
  }
}`;
  }
}