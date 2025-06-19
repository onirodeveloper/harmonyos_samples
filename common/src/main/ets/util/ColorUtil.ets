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
  /**
   * Generate an immersive background color for the image.
   * @Prop rRGB
   * @Prop gRGB
   * @Prop bRGB
   * @returns
   */
  public static getDeepenImmersionColor(rRGB: number, gRGB: number, bRGB: number): number[] {
    const hsb: number[] = ColorUtil.rgbToHsb(rRGB, gRGB, bRGB);
    const hHSB = hsb[0];
    let sHSB = hsb[1];
    let bHSB = hsb[2];
    sHSB = sHSB + 0.35;
    if (bHSB > 0.15) {
      bHSB = bHSB - 0.4;
      if (bHSB < 0.15) {
        bHSB = 0.15;
      }
    }
    return ColorUtil.hsbToRgb(hHSB, sHSB, bHSB);
  }

  private static rgbToHsb(rRGB: number, gRGB: number, bRGB: number): [hHsb: number, sHsb: number, bHsb: number] {
    const max = Math.max(rRGB, gRGB, bRGB);
    const min = Math.min(rRGB, gRGB, bRGB);
    const sHSB = max === 0 ? 0 : (max - min) / max;
    const bHSB = (max + 10) / 255;
    let hHSB = 0;
    if (max === rRGB && gRGB >= bRGB) {
      hHSB = 60 * (gRGB - bRGB) / (max - min) + 0;
    }
    if (max === rRGB && gRGB < bRGB) {
      hHSB = 60 * (gRGB - bRGB) / (max - min) + 360;
    }
    if (max === gRGB) {
      hHSB = 60 * (bRGB - rRGB) / (max - min) + 120;
    }
    if (max === bRGB) {
      hHSB = 60 * (rRGB - gRGB) / (max - min) + 240;
    }
    return [hHSB, sHSB, bHSB];
  }

  private static hsbToRgb(hHSB: number, sHSB: number, bHSB: number): number[] {
    const i: number = Math.floor((hHSB / 60) % 6);
    const f = (hHSB / 60) - i;
    const p = bHSB * (1 - sHSB);
    const q = bHSB * (1 - f * sHSB);
    const t = bHSB * (1 - (1 - f) * sHSB);
    let rRGB = bHSB;
    let gRGB = t;
    let bRGB = p;
    switch (i) {
      case 0:
        rRGB = bHSB;
        gRGB = t;
        bRGB = p;
        break;
      case 1:
        rRGB = q;
        gRGB = bHSB;
        bRGB = p;
        break;
      case 2:
        rRGB = p;
        gRGB = bHSB;
        bRGB = t;
        break;
      case 3:
        rRGB = p;
        gRGB = q;
        bRGB = bHSB;
        break;
      case 4:
        rRGB = t;
        gRGB = p;
        bRGB = bHSB;
        break;
      case 5:
        rRGB = bHSB;
        gRGB = p;
        bRGB = q;
        break;
      default:
        break;
    }
    return [Math.max(0, Math.floor(rRGB * 255.0)), Math.max(0, Math.floor(gRGB * 255.0)),
      Math.max(0, Math.floor(bRGB * 255.0))];
  }
}