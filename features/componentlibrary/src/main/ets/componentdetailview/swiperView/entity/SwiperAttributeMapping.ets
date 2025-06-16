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

type IndicatorType = DotIndicator | DigitIndicator | boolean;

class IndicatorMap {
  public readonly code: string;
  public readonly value: IndicatorType;

  constructor(code: string, value: IndicatorType) {
    this.code = code;
    this.value = value;
  }
}

const dotIndicatorCode: string = `new DotIndicator()
      .itemWidth(6)
      .itemHeight(6)
      .selectedItemWidth(12)
      .selectedItemHeight(6)
      .color($r('sys.color.comp_background_secondary'))
      .selectedColor($r('sys.color.comp_background_emphasize'))`;

const digitIndicatorCode: string = `new DigitIndicator()
      .fontColor($r('sys.color.font_primary'))
      .selectedFontColor($r('sys.color.font_primary'))
      .digitFont({ size: 16, weight: FontWeight.Bold })`;

export const indicatorStyleMapData: Map<string, IndicatorMap> = new Map([
  ['DotIndicator', new IndicatorMap(dotIndicatorCode, new DotIndicator().itemWidth(6)
    .itemHeight(6)
    .selectedItemWidth(12)
    .selectedItemHeight(6)
    .color($r('sys.color.comp_background_secondary'))
    .selectedColor($r('sys.color.comp_background_emphasize')))],
  ['DigitIndicator', new IndicatorMap(digitIndicatorCode, new DigitIndicator().fontColor($r('sys.color.font_primary'))
    .selectedFontColor($r('sys.color.font_primary'))
    .digitFont({ size: 16, weight: FontWeight.Bold }))],
  ['None', new IndicatorMap('false', false)],
  ['Default', new IndicatorMap(dotIndicatorCode, new DotIndicator().itemWidth(6)
    .itemHeight(6)
    .selectedItemWidth(12)
    .selectedItemHeight(6)
    .color($r('sys.color.comp_background_secondary'))
    .selectedColor($r('sys.color.comp_background_emphasize')))],
]);

export class IndicatorEffectMap {
  public readonly code: string;
  public readonly value: EdgeEffect;

  constructor(code: string, value: EdgeEffect) {
    this.code = code;
    this.value = value;
  }
}

export const indicatorEffectMapping: Map<string, IndicatorEffectMap> = new Map([
  ['Default', new IndicatorEffectMap('EdgeEffect.Spring', EdgeEffect.Spring)],
  ['Spring', new IndicatorEffectMap('EdgeEffect.Spring', EdgeEffect.Spring)],
  ['Fade', new IndicatorEffectMap('EdgeEffect.Fade', EdgeEffect.Fade)],
  ['None', new IndicatorEffectMap('EdgeEffect.None', EdgeEffect.None)],
]);