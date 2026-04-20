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

import { HdsListItemCard, SuffixSwitch } from '@kit.UIDesignKit';
import type { ToggleComAttribute } from '../viewmodel/ComponentDetailState';

/**
 * Toggle Public Component
 */
@Component
export struct ToggleComponent {
  @ObjectLink attribute: ToggleComAttribute;
  callback: (name: string, value: string) => void = (_name: string, _value: string) => {
  };

  build() {
    HdsListItemCard({
      textItem: {
        primaryText: { text: this.attribute.displayName }
      },
      suffixItem: new SuffixSwitch({
        isCheck: (this.attribute.currentValue?.toLowerCase() === 'true'),
        selectColor: $r('sys.color.comp_background_emphasize'),
        onChange: (isOn: boolean) => {
          this.callback(this.attribute.name, isOn ? 'true' : 'false');
        },
      }),
      cardHeight: $r('app.float.common_component_height'),
      cardPrefixMargin: $r('sys.float.padding_level2'),
      cardSuffixMargin: $r('sys.float.padding_level2'),
    })
  }
}