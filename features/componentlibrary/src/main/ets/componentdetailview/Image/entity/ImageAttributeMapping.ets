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

class ImageFitStyleMap {
  public code: string;
  public value: ImageFit;

  constructor(code: string, value: ImageFit) {
    this.code = code;
    this.value = value;
  }
}

export const imageFitStyleMapData: Map<string, ImageFitStyleMap> = new Map([
  ['Default', new ImageFitStyleMap('ImageFit.Cover', ImageFit.Cover)],
  ['Contain', new ImageFitStyleMap('ImageFit.Contain', ImageFit.Contain)],
  ['Cover', new ImageFitStyleMap('ImageFit.Cover', ImageFit.Cover)],
  ['Auto', new ImageFitStyleMap('ImageFit.Auto', ImageFit.Auto)],
  ['Fill', new ImageFitStyleMap('ImageFit.Fill', ImageFit.Fill)],
  ['ScaleDown', new ImageFitStyleMap('ImageFit.ScaleDown', ImageFit.ScaleDown)],
  ['None', new ImageFitStyleMap('ImageFit.None', ImageFit.None)],
  ['TopStart', new ImageFitStyleMap('ImageFit.TOP_START', ImageFit.TOP_START)],
  ['Top', new ImageFitStyleMap('ImageFit.TOP', ImageFit.TOP)],
  ['TopEnd', new ImageFitStyleMap('ImageFit.TOP_END', ImageFit.TOP_END)],
  ['Start', new ImageFitStyleMap('ImageFit.START', ImageFit.START)],
  ['Center', new ImageFitStyleMap('ImageFit.CENTER', ImageFit.CENTER)],
  ['End', new ImageFitStyleMap('ImageFit.END', ImageFit.END)],
  ['Bottom', new ImageFitStyleMap('ImageFit.BOTTOM', ImageFit.BOTTOM)],
  ['BottomStart', new ImageFitStyleMap('ImageFit.BOTTOM_START', ImageFit.BOTTOM_START)],
  ['BottomEnd', new ImageFitStyleMap('ImageFit.BOTTOM_END', ImageFit.BOTTOM_END)],
]);

class FilterStyleMap {
  public code: string;
  public value: string;

  constructor(code: string, value: string) {
    this.code = code;
    this.value = value;
  }
}

export const filterStyleMapData: Map<string, FilterStyleMap> = new Map([
  // The input parameter is a 4x5 RGBA conversion matrix.
  ['无滤镜', new FilterStyleMap('1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0', '1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0')],
  ['色彩旋转',
    new FilterStyleMap('0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0', '0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0')],
  ['灰色滤镜',
    new FilterStyleMap('0.3086,0.6094,0.0820,0,0,0.3086,0.6094,0.0820,0,0,0.3086,0.6094,0.0820,0,0,0,0,0,1,0',
      '0.3086,0.6094,0.0820,0,0,0.3086,0.6094,0.0820,0,0,0.3086,0.6094,0.0820,0,0,0,0,0,1,0')],
  ['增色滤镜',
    new FilterStyleMap('1,0,0,0,0,0,1,0,0,255,0,0,1,0,0,0,0,0,1,0', '1,0,0,0,0,0,1,0,0,255,0,0,1,0,0,0,0,0,1,0')],
  ['Default', new FilterStyleMap('1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0', '1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0')]
]);