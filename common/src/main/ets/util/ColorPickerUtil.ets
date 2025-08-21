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

enum ColorAreaEnum {
  RED = 0,
  YELLOW = 1,
  GREEN = 2,
  CYAN = 3,
  BLUE = 4,
  FUCHSIA = 5,
}

export class ColorPickerUtil {
  // Constants for color segmentation.
  private static readonly COLOR_SEGMENTS = 6;
  private static readonly MAX_RGB_VALUE = 255;
  private static readonly FULL_OPACITY = 1.0;
  // Constants for RGB string processing. Length of "rgba(".
  private static readonly RGB_PREFIX_LENGTH = 5;
  // Constants for color segment boundaries.
  public static readonly SEGMENT_1 = 1 / 6;
  public static readonly SEGMENT_2 = 2 / 6;
  public static readonly SEGMENT_3 = 3 / 6;
  public static readonly SEGMENT_4 = 4 / 6;
  public static readonly SEGMENT_5 = 5 / 6;
  public static readonly SEGMENT_6 = 6 / 6;

  /**
   * Creates an RGBA color string from component values
   * @param red Red component (0-255)
   * @param green Green component (0-255)
   * @param blue Blue component (0-255)
   * @param opacity Opacity (0.0-1.0)
   * @returns Formatted RGBA string
   */
  public static setRgba(red: number, green: number, blue: number, opacity: number): string {
    return `rgba(${red},${green},${blue},${opacity})`;
  }

  /**
   * Calculates a color based on slider position
   * @param value Slider value (0-100)
   * @returns RGBA color string
   */
  public static getBlockColor(value: number): string {
    // Calculate the corresponding color based on the area of the slider.colorPercent(0-1)
    const colorPercent = value / 100 * ColorPickerUtil.COLOR_SEGMENTS;
    let selectedColor: string = '';
    const colorSegment: number = Math.trunc(colorPercent);
    const colorAreaPercent: number = colorPercent - colorSegment;
    switch (colorSegment) {
      case ColorAreaEnum.RED:
        selectedColor = ColorPickerUtil.setRgba(ColorPickerUtil.MAX_RGB_VALUE,
          Math.floor(colorAreaPercent * ColorPickerUtil.MAX_RGB_VALUE), 0, ColorPickerUtil.FULL_OPACITY);
        break;
      case ColorAreaEnum.YELLOW:
        selectedColor = ColorPickerUtil.setRgba(Math.floor(((1 - colorAreaPercent) * ColorPickerUtil.MAX_RGB_VALUE)),
          ColorPickerUtil.MAX_RGB_VALUE, 0, ColorPickerUtil.FULL_OPACITY);
        break;
      case ColorAreaEnum.GREEN:
        selectedColor = ColorPickerUtil.setRgba(0, ColorPickerUtil.MAX_RGB_VALUE,
          Math.floor(colorAreaPercent * ColorPickerUtil.MAX_RGB_VALUE), ColorPickerUtil.FULL_OPACITY);
        break;
      case ColorAreaEnum.CYAN:
        selectedColor = ColorPickerUtil.setRgba(0, Math.floor(((1 - colorAreaPercent) * ColorPickerUtil.MAX_RGB_VALUE)),
          ColorPickerUtil.MAX_RGB_VALUE, ColorPickerUtil.FULL_OPACITY);
        break;
      case ColorAreaEnum.BLUE:
        selectedColor = ColorPickerUtil.setRgba(Math.floor(colorAreaPercent * ColorPickerUtil.MAX_RGB_VALUE), 0,
          ColorPickerUtil.MAX_RGB_VALUE, ColorPickerUtil.FULL_OPACITY);
        break;
      case ColorAreaEnum.FUCHSIA:
        selectedColor = ColorPickerUtil.setRgba(ColorPickerUtil.MAX_RGB_VALUE, 0,
          Math.floor(((1 - colorAreaPercent) * ColorPickerUtil.MAX_RGB_VALUE)), ColorPickerUtil.FULL_OPACITY);
        break;
      default:
        selectedColor = ColorPickerUtil.setRgba(ColorPickerUtil.MAX_RGB_VALUE, 0, 0, ColorPickerUtil.FULL_OPACITY);
    }
    return selectedColor;
  }

  /**
   * Calculate the color number of red, blue, green area.
   * @param rgb, rgba(0, 255, 1, 1.00)
   * @returns the number of three area.
   */
  public static getRgb(rgb: string): number[] {
    rgb = rgb.substring(ColorPickerUtil.RGB_PREFIX_LENGTH, rgb.length - 1);
    const rgbArray = rgb.split(',');
    const redArea: number = parseFloat(rgbArray[0]);
    const greenArea: number = parseFloat(rgbArray[1]);
    const blueArea: number = parseFloat(rgbArray[2]);
    return [redArea, greenArea, blueArea];
  }

  /**
   * Calculate the color accord to red, blue, green area.
   * @param rgb, rgba(0, 255, 1, 1.00)
   * @returns color number (0-100)
   */
  public static getColorFromRgb(rgb: string): number {
    const rgbArray = ColorPickerUtil.getRgb(rgb);
    const redArea: number = rgbArray[0];
    const greenArea: number = rgbArray[1];
    const blueArea: number = rgbArray[2];
    let colorArea: number = 0.00;
    if (redArea === ColorPickerUtil.MAX_RGB_VALUE && blueArea === 0) {
      colorArea = ColorAreaEnum.RED + greenArea / ColorPickerUtil.MAX_RGB_VALUE;
    } else if (greenArea === ColorPickerUtil.MAX_RGB_VALUE && blueArea === 0) {
      colorArea = ColorAreaEnum.YELLOW + (redArea / ColorPickerUtil.MAX_RGB_VALUE);
    } else if (redArea === 0 && greenArea === ColorPickerUtil.MAX_RGB_VALUE) {
      colorArea = ColorAreaEnum.GREEN + (blueArea / ColorPickerUtil.MAX_RGB_VALUE);
    } else if (redArea === 0 && blueArea === ColorPickerUtil.MAX_RGB_VALUE) {
      colorArea = ColorAreaEnum.CYAN + (greenArea / ColorPickerUtil.MAX_RGB_VALUE);
    } else if (greenArea === 0 && blueArea === ColorPickerUtil.MAX_RGB_VALUE) {
      colorArea = ColorAreaEnum.BLUE + (redArea / ColorPickerUtil.MAX_RGB_VALUE);
    } else if (redArea === ColorPickerUtil.MAX_RGB_VALUE && greenArea === 0) {
      colorArea = ColorAreaEnum.FUCHSIA + (blueArea / ColorPickerUtil.MAX_RGB_VALUE);
    }
    const colorPercent = colorArea / ColorPickerUtil.COLOR_SEGMENTS * 100;
    return colorPercent;
  }
}