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

import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI';
import type { ToggleButtonAttribute } from '../viewmodel/ComponentDetailState';

@Component
export struct ToggleButtonComponent {
  @ObjectLink attribute: ToggleButtonAttribute;
  @State @Watch('onChangeSelectIndex') selectIndex: number[] =
    [this.attribute.selectOption.findIndex((item) => item?.text === this.attribute.currentValue)];
  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: this.attribute.selectOption as ItemRestriction<SegmentButtonTextItem>,
    multiply: false,
    selectedFontColor: $r('sys.color.font_primary'),
    fontColor: $r('sys.color.font_secondary'),
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable'),
  });
  callback: (name: string, value: string) => void = (name: string, value: string) => {
  };

  onChangeSelectIndex() {
    if (this.selectIndex) {
      const index = this.selectIndex[0];
      this.callback(this.attribute.name, this.attribute.selectOption[index]?.text as string);
    }
  }

  build() {
    Row() {
      Text(this.attribute.disPlayName)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
      Blank()
      SegmentButton({
        options: this.singleSelectCapsuleOptions,
        selectedIndexes: $selectIndex
      }).width('60%')
    }
    .height($r('app.float.common_component_height'))
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    .alignItems(VerticalAlign.Center)
    .width('100%')
  }
}