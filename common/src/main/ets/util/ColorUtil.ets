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

/**
 * Color conversion processing class.
 */
export class ColorUtil {
  // Color adjustment constants
  private static readonly SATURATION_INCREMENT = 0.35;
  private static readonly BRIGHTNESS_DECREMENT = 0.4;
  private static readonly MIN_BRIGHTNESS = 0.15;
  private static readonly BRIGHTNESS_OFFSET = 10;
  private static readonly MAX_RGB = 255;

  // HSB conversion constants
  private static readonly HUE_SEGMENTS = 6;
  private static readonly DEGREES_PER_SEGMENT = 60;
  private static readonly FULL_CIRCLE_DEGREES = 360;

  // Color component indices
  private static readonly HUE_INDEX = 0;
  private static readonly SATURATION_INDEX = 1;
  private static readonly BRIGHTNESS_INDEX = 2;

  /**
   * Generates an immersive background color by adjusting saturation and brightness
   * @param rRGB Red component (0-255)
   * @param gRGB Green component (0-255)
   * @param bRGB Blue component (0-255)
   * @returns Adjusted RGB values as [r, g, b]
   */
  public static getDeepenImmersionColor(rRGB: number, gRGB: number, bRGB: number): number[] {
    const hsb = ColorUtil.rgbToHsb(rRGB, gRGB, bRGB);
    let saturation = hsb[ColorUtil.SATURATION_INDEX];
    let brightness = hsb[ColorUtil.BRIGHTNESS_INDEX];

    // Increase saturation
    saturation += ColorUtil.SATURATION_INCREMENT;

    // Decrease brightness with minimum threshold
    if (brightness > ColorUtil.MIN_BRIGHTNESS) {
      brightness -= ColorUtil.BRIGHTNESS_DECREMENT;
      brightness = Math.max(brightness, ColorUtil.MIN_BRIGHTNESS);
    }

    return ColorUtil.hsbToRgb(
      hsb[ColorUtil.HUE_INDEX],
      saturation,
      brightness
    );
  }

  /**
   * Converts RGB color values to HSB (HSV) color space
   * @param rRGB Red component (0-255)
   * @param gRGB Green component (0-255)
   * @param bRGB Blue component (0-255)
   * @returns HSB values as [hue, saturation, brightness]
   */
  private static rgbToHsb(
    rRGB: number,
    gRGB: number,
    bRGB: number
  ): [number, number, number] {
    const normalizedR = rRGB / ColorUtil.MAX_RGB;
    const normalizedG = gRGB / ColorUtil.MAX_RGB;
    const normalizedB = bRGB / ColorUtil.MAX_RGB;
    const max = Math.max(normalizedR, normalizedG, normalizedB);
    const min = Math.min(normalizedR, normalizedG, normalizedB);
    const delta = max - min;
    let hue = 0;
    const saturation = max === 0 ? 0 : delta / max;
    const brightness = (max * ColorUtil.MAX_RGB + ColorUtil.BRIGHTNESS_OFFSET) / ColorUtil.MAX_RGB;

    if (delta !== 0) {
      if (max === normalizedR) {
        hue = ColorUtil.DEGREES_PER_SEGMENT * ((normalizedG - normalizedB) / delta % ColorUtil.HUE_SEGMENTS);
      } else if (max === normalizedG) {
        hue = ColorUtil.DEGREES_PER_SEGMENT * ((normalizedB - normalizedR) / delta + 2);
      } else {
        hue = ColorUtil.DEGREES_PER_SEGMENT * ((normalizedR - normalizedG) / delta + 4);
      }
      if (hue < 0) {
        hue += ColorUtil.FULL_CIRCLE_DEGREES;
      }
    }

    return [hue, saturation, brightness];
  }

  /**
   * Converts HSB (HSV) color values back to RGB color space
   * @param hue Hue in degrees (0-360)
   * @param saturation Saturation (0-1)
   * @param brightness Brightness (0-1)
   * @returns RGB values as [r, g, b] in 0-255 range
   */
  private static hsbToRgb(
    hue: number,
    saturation: number,
    brightness: number
  ): number[] {
    const segment = Math.floor((hue / ColorUtil.DEGREES_PER_SEGMENT) % ColorUtil.HUE_SEGMENTS);
    const fractional = (hue / ColorUtil.DEGREES_PER_SEGMENT) - segment;
    const p = brightness * (1 - saturation);
    const q = brightness * (1 - fractional * saturation);
    const t = brightness * (1 - (1 - fractional) * saturation);
    // rgb
    let r = brightness;
    let g = t;
    let b = p;
    switch (segment) {
      case 0:
        r = brightness;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = brightness;
        b = p;
        break;
      case 2:
        r = p;
        g = brightness;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = brightness;
        break;
      case 4:
        r = t;
        g = p;
        b = brightness;
        break;
      case 5:
        r = brightness;
        g = p;
        b = q;
        break;
      default:
        r = 0;
        g = 0;
        b = 0;
        break;
    }
    const scaleToRgb = (value: number) => Math.max(0, Math.floor(value * ColorUtil.MAX_RGB));
    return [
      scaleToRgb(r),
      scaleToRgb(g),
      scaleToRgb(b)
    ];
  }
}