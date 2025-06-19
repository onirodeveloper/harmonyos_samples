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

import type { ObservedArray } from '@ohos/common';
import { VibratorUtils } from '@ohos/common';
import type { Attribute } from '../viewmodel/Attribute';
import { ColorPickerComponent } from './ColorPickerComponent';
import { SelectComponent } from './SelectComponent';
import { SliderComponent } from './SliderComponent';
import { ToggleComponent } from './ToggleComponent';
import { OpacityComponent } from './OpacityComponent';
import { ToggleButtonComponent } from './ToggleButtonComponent';
import { AttributeTypeEnum } from '../viewmodel/AttributeTypeEnum';
import {
  ColorPickerAttribute,
  OpacityPickerAttribute,
  SelectComAttribute,
  SliderComAttribute,
  ToggleButtonAttribute,
  ToggleComAttribute,
} from '../viewmodel/ComponentDetailState';
import { ChangeAttributeEvent, ComponentDetailPageVM } from '../viewmodel/ComponentDetailPageVM';
import { ComponentDetailManager } from '../viewmodel/ComponentDetailManager';

@Component
export struct AttributeChangeArea {
  @ObjectLink @Watch('getAttributeData') attributes: ObservedArray<Attribute>;
  @Prop componentName: string;
  @State attributeDataTwo: Attribute[] = [];
  @State attributeDataOne: Attribute[] = [];
  @State attributeDataTwoLength: number = 0;
  @State attributeDataOneLength: number = 0;

  aboutToAppear(): void {
    this.getAttributeData();
  }

  eventCallback = (name: string, value: string, mode?: SliderChangeMode) => {
    const viewModel: ComponentDetailPageVM | undefined =
      ComponentDetailManager.getInstance().getDetailViewModel(this.componentName);
    viewModel?.sendEvent(new ChangeAttributeEvent(name, value));
    if (mode && (mode === SliderChangeMode.Moving)) {
      VibratorUtils.startVibration();
    }
  }

  getAttributeData() {
    const attributeDataOne: Attribute[] = [];
    const attributeDataTwo: Attribute[] = [];
    this.attributes.forEach((item: Attribute) => {
      if ([AttributeTypeEnum.TOGGLE_BUTTON, AttributeTypeEnum.TOGGLE, AttributeTypeEnum.SLIDER,
        AttributeTypeEnum.SELECT].includes(item.type)) {
        attributeDataOne.push(item);
      } else {
        attributeDataTwo.push(item);
      }
    });
    this.attributeDataTwoLength = attributeDataTwo.length;
    this.attributeDataOneLength = attributeDataOne.length;
    this.attributeDataTwo = attributeDataTwo;
    this.attributeDataOne = attributeDataOne;
  }

  build() {
    Column() {
      if (this.attributeDataOneLength !== 0) {
        Column() {
          ForEach(this.attributeDataOne, (item: Attribute, index: number) => {
            if (index !== 0) {
              Divider()
                .color($r('sys.color.comp_background_tertiary'))
                .width('100%')
                .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
            }
            if (item instanceof SelectComAttribute) {
              SelectComponent({ attribute: item, callback: this.eventCallback })
            } else if (item instanceof ToggleButtonAttribute) {
              ToggleButtonComponent({ attribute: item, callback: this.eventCallback })
            } else if (item instanceof SliderComAttribute) {
              SliderComponent({ attribute: item, callback: this.eventCallback })
            } else if (item instanceof ToggleComAttribute) {
              ToggleComponent({ attribute: item, callback: this.eventCallback })
            }
          }, (item: Attribute, _index: number) => item.name)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2'),
        })
        .margin({ bottom: this.attributeDataTwoLength === 0 ? 0 : $r('sys.float.padding_level8') })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius($r('sys.float.corner_radius_level8'))
      }

      if (this.attributeDataTwoLength !== 0) {
        Column() {
          ForEach(this.attributeDataTwo, (item: Attribute, index: number) => {
            if (index !== 0) {
              Divider()
                .color($r('sys.color.comp_background_tertiary'))
                .width('100%')
                .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
            }
            if (item instanceof ColorPickerAttribute) {
              ColorPickerComponent({ attribute: item, callback: this.eventCallback })
            } else if (item instanceof OpacityPickerAttribute) {
              OpacityComponent(item, this.eventCallback)
            }
          }, (item: Attribute, _index: number) => item.name)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2'),
        })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius($r('sys.float.corner_radius_level8'))
      }
    }
  }
}