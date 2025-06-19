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

import { CommonColorMapping, CommonNumberMapping, CommonStringMapping } from '../../common/entity/CommonMapData';

class StyleMapping {
  public readonly code: string;
  public readonly value: CommonProgressStyleOptions;

  constructor(code: string, value: CommonProgressStyleOptions) {
    this.code = code;
    this.value = value;
  }
}

export const progressStyleMapData: Map<string, StyleMapping> = new Map([
  ['LinearStyle', new StyleMapping('{ strokeWidth: 4, enableSmoothEffect: true }',
    { strokeWidth: 4, enableSmoothEffect: true } as LinearStyleOptions)],
  ['ProgressStyle', new StyleMapping('{ strokeWidth: 4, scaleCount: 20, scaleWidth: 4 }',
    { strokeWidth: 4, scaleCount: 20, scaleWidth: 4 } as ProgressStyleOptions)],
  ['RingStyle1', new StyleMapping('{ strokeWidth: 4, enableScanEffect: true }',
    { strokeWidth: 4, enableScanEffect: true } as ProgressStyleOptions)],
  ['RingStyle2',
    new StyleMapping('{ strokeWidth: 4, shadow: true }', { strokeWidth: 4, shadow: true } as RingStyleOptions)],
  ['EclipseStyle', new StyleMapping('{ strokeWidth: 4, enableSmoothEffect: true }',
    { strokeWidth: 4, enableSmoothEffect: true } as EclipseStyleOptions)],
  ['ScaleRingStyle', new StyleMapping('{ strokeWidth: 4, scaleCount: 15, scaleWidth: 50 }',
    { strokeWidth: 4, scaleCount: 15, scaleWidth: 50 } as ScaleRingStyleOptions)],
  ['CapsuleStyle', new StyleMapping(`{
          borderWidth: 1,
          enableScanEffect: false,
          fontColor: Color.Gray,
          showDefaultPercentage: true,
        }`, {
    borderWidth: 1,
    enableScanEffect: false,
    fontColor: Color.Gray,
    showDefaultPercentage: true,
  } as CapsuleStyleOptions)],
  ['Default', new StyleMapping('{ strokeWidth: 4, enableSmoothEffect: true }',
    { strokeWidth: 4, enableSmoothEffect: true } as LinearStyleOptions)],
]);

class ProgressTypeMap {
  public readonly code: string;
  public readonly value: ProgressType;

  constructor(code: string, value: ProgressType) {
    this.code = code;
    this.value = value;
  }
}

export const progressTypeMapData: Map<string, ProgressTypeMap> = new Map([
  ['LinearStyle', new ProgressTypeMap('ProgressType.Linear', ProgressType.Linear)],
  ['ProgressStyle', new ProgressTypeMap('ProgressType.Ring', ProgressType.Ring)],
  ['RingStyle1', new ProgressTypeMap('ProgressType.Ring', ProgressType.Ring)],
  ['RingStyle2', new ProgressTypeMap('ProgressType.Ring', ProgressType.Ring)],
  ['EclipseStyle', new ProgressTypeMap('ProgressType.Eclipse', ProgressType.Eclipse)],
  ['ScaleRingStyle', new ProgressTypeMap('ProgressType.ScaleRing', ProgressType.ScaleRing)],
  ['CapsuleStyle', new ProgressTypeMap('ProgressType.Capsule', ProgressType.Capsule)],
  ['Default', new ProgressTypeMap('ProgressType.Linear', ProgressType.Linear)],
]);

export const progressValueMapData: Map<string, CommonNumberMapping> = new Map([
  ['Default', new CommonNumberMapping('10', 10)],
]);

export const progressColorMapData: Map<string, CommonColorMapping> = new Map([
  ['Default', new CommonColorMapping('rgba(0,85,255,1.00)', 'rgba(0,85,255,1.00)')],
]);

export const progressKindMapData: Map<string, CommonStringMapping> = new Map([
  ['Progress', new CommonStringMapping('Progress', 'Progress')],
  ['LoadingProgress', new CommonStringMapping('LoadingProgress', 'LoadingProgress')],
  ['Default', new CommonStringMapping('LoadingProgress', 'LoadingProgress')],
]);