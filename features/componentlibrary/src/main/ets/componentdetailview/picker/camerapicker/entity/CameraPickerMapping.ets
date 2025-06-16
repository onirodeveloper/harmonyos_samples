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

import { cameraPicker } from '@kit.CameraKit';

class CameraMediaType {
  public code: string;
  public value: cameraPicker.PickerMediaType[];

  constructor(code: string, value: cameraPicker.PickerMediaType[]) {
    this.code = code;
    this.value = value;
  }
}

export const pickerMediaType: Map<string, CameraMediaType> = new Map([
  ['Default', new CameraMediaType('[cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO]',
    [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO])],
  ['拍照模式', new CameraMediaType('[cameraPicker.PickerMediaType.PHOTO]', [cameraPicker.PickerMediaType.PHOTO])],
  ['录制模式', new CameraMediaType('[cameraPicker.PickerMediaType.VIDEO]', [cameraPicker.PickerMediaType.VIDEO])],
  ['混合模式', new CameraMediaType('[cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO]',
    [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO])],
]);