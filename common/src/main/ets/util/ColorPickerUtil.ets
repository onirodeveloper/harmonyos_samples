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

export class ColorPickerUtil {
  private static currentColor: string;

  public static setRgba(red: number, green: number, blue: number, opacity: number): string {
    return `rgba(${red},${green},${blue},${opacity})`;
  }

  public static getRgbText() {
    return ColorPickerUtil.currentColor;
  }

  public static getBlockColor(value: number): string {
    // Calculate the corresponding color based on the area of the slider.
    const colorPercent = value / 100;
    let selectedColor: string = '';
    let colorAreaPercent: number = 0;
    if (colorPercent >= 0 && colorPercent <= 1 / 6) {
      colorAreaPercent = colorPercent * 6;
      selectedColor = ColorPickerUtil.setRgba(255, Math.floor(colorAreaPercent * 255), 0, 1.00);
    } else if (colorPercent >= 1 / 6 && colorPercent <= 2 / 6) {
      colorAreaPercent = (colorPercent - 1 / 6) * 6;
      selectedColor = ColorPickerUtil.setRgba(Math.floor(((1 - colorAreaPercent) * 255)), 255, 0, 1.00);
    } else if (colorPercent >= 2 / 6 && colorPercent <= 3 / 6) {
      colorAreaPercent = (colorPercent - 2 / 6) * 6;
      selectedColor = ColorPickerUtil.setRgba(0, 255, Math.floor(colorAreaPercent * 255), 1.00);
    } else if (colorPercent >= 3 / 6 && colorPercent <= 4 / 6) {
      colorAreaPercent = (colorPercent - 3 / 6) * 6;
      selectedColor = ColorPickerUtil.setRgba(0, Math.floor(((1 - colorAreaPercent) * 255)), 255, 1.00);
    } else if (colorPercent >= 4 / 6 && colorPercent <= 5 / 6) {
      colorAreaPercent = (colorPercent - 4 / 6) * 6;
      selectedColor = ColorPickerUtil.setRgba(Math.floor(colorAreaPercent * 255), 0, 255, 1.00);
    } else if (colorPercent >= 5 / 6 && colorPercent <= 6 / 6) {
      colorAreaPercent = (colorPercent - 5 / 6) * 6;
      selectedColor = ColorPickerUtil.setRgba(255, 0, Math.floor(((1 - colorAreaPercent) * 255)), 1.00);
    }
    ColorPickerUtil.currentColor = `${selectedColor.substring(4, selectedColor.length - 3)})`;
    return selectedColor;
  }

  public static getRgb(rgb: string): number[] {
    rgb = rgb.substring(5, rgb.length - 1);
    const rgbArray = rgb.split(',');
    const redArea: number = parseFloat(rgbArray[0]);
    const greenArea: number = parseFloat(rgbArray[1]);
    const blueArea: number = parseFloat(rgbArray[2]);
    return [redArea, greenArea, blueArea];
  }

  public static getColorFromRgb(rgb: string): number {
    const rgbArray = ColorPickerUtil.getRgb(rgb);
    const redArea: number = rgbArray[0];
    const greenArea: number = rgbArray[1];
    const blueArea: number = rgbArray[2];
    const allColorCount = 255 * 6;
    let colorPercent: number = 0.00;
    if (redArea === 255 && blueArea === 0) {
      colorPercent = greenArea / allColorCount;
    } else if (greenArea === 255 && blueArea === 0) {
      colorPercent = (redArea + 255) / allColorCount;
    } else if (redArea === 0 && greenArea === 255) {
      colorPercent = (blueArea + 255 * 2) / allColorCount;
    } else if (redArea === 0 && blueArea === 255) {
      colorPercent = (greenArea + 255 * 3) / allColorCount;
    } else if (greenArea === 0 && blueArea === 255) {
      colorPercent = (redArea + 255 * 4) / allColorCount;
    } else if (redArea === 255 && greenArea === 0) {
      colorPercent = (blueArea + 255 * 5) / allColorCount;
    }
    return colorPercent * 100;
  }
}