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

import { ItemRestriction, SegmentButtonTextItem } from '@kit.ArkUI';
import type { TopNavigationData } from '@ohos/common';
import { BaseState, LoadingStatus, ObservedArray } from '@ohos/common';
import type { CommonDescriptor } from './CommonDescriptor';
import type { AttributeData, RecommendData } from '../model/ComponentDetailData';
import { Attribute } from './Attribute';
import { AttributeTypeEnum } from './AttributeTypeEnum';

@Observed
export class ComponentDetailState extends BaseState {
  public descriptor: CommonDescriptor;
  public attributes: ObservedArray<Attribute>;
  public code: string;
  public recommends: RecommendData[];
  public loadingStatus: LoadingStatus;
  public topNavigationData: TopNavigationData;

  constructor(
    descriptor: CommonDescriptor,
    attributes: ObservedArray<Attribute>,
    code: string,
    recommends: RecommendData[],
    loadingStatus: LoadingStatus,
    topNavigationData: TopNavigationData,
  ) {
    super();
    this.descriptor = descriptor;
    this.attributes = attributes;
    this.code = code;
    this.recommends = recommends;
    this.loadingStatus = loadingStatus;
    this.topNavigationData = topNavigationData;
  }
}

/**
 * Six component-shown.
 */

@Observed
export class SelectComAttribute extends Attribute {
  public selectOption: SelectOption[] = [];
}

@Observed
export class ToggleButtonAttribute extends Attribute {
  public selectOption: ItemRestriction<SegmentButtonTextItem> =
    [{} as SegmentButtonTextItem, {} as SegmentButtonTextItem];
}

@Observed
export class SliderComAttribute extends Attribute {
  public leftRange: number = 0;
  public rightRange: number = 0;
  public step: number = 1;
}

@Observed
export class ColorPickerAttribute extends Attribute {
}

@Observed
export class OpacityPickerAttribute extends Attribute {
  public leftRange: number = 0;
  public rightRange: number = 0;
  public step: number = 1;
}

@Observed
export class ToggleComAttribute extends Attribute {
}

/**
 * Get the component-shown by attributeData displayType.
 *
 * @param attributeData
 * @returns
 */
export function getEnumType(attributeData: AttributeData): AttributeTypeEnum {
  switch (attributeData.displayType) {
    case 'enum':
      return JSON.parse(attributeData.propertyValues).length > 2 ? AttributeTypeEnum.SELECT :
      AttributeTypeEnum.TOGGLE_BUTTON;
    case 'boolean':
      return AttributeTypeEnum.TOGGLE;
    case 'number':
      return AttributeTypeEnum.SLIDER;
    case 'color':
      return AttributeTypeEnum.COLOR;
    case 'opacity':
      return AttributeTypeEnum.OPACITY;
  }
  return AttributeTypeEnum.SELECT;
}