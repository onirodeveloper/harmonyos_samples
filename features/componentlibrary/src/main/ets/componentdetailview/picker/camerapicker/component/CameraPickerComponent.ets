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

import type { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import type { BusinessError } from '@kit.BasicServicesKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { Logger } from '@ohos/common';
import type { CameraPickerDescriptor } from '../viewmodel/CameraPickerDescriptor';

const TAG: string = '[CameraPickerBuilder]';
const CODE_SUCC: number = 0;

@Component
export struct CameraPickerComponent {
  @Prop cameraPickerDescriptor: CameraPickerDescriptor;
  @State uri?: ResourceStr = undefined;
  @State mediaType: cameraPicker.PickerMediaType = cameraPicker.PickerMediaType.PHOTO;
  @State isFilled: boolean = false;
  @State cameraNum: number = 0;
  private controller: VideoController = new VideoController();

  aboutToAppear() {
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    let cameraManager: camera.CameraManager;
    try {
      cameraManager = camera.getCameraManager(context);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `GetCameraManager error, the code is ${error.code}, the message is ${error.message}`);
      return;
    }
    const cameraArray: camera.CameraDevice[] = this.getSupportedCameras(cameraManager);
    this.cameraNum = cameraArray.length;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.mediaType === cameraPicker.PickerMediaType.VIDEO) {
        Video({ src: this.uri, controller: this.controller })
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius($r('sys.float.corner_radius_level8'))
          .onPrepared(() => {
            this.controller.setCurrentTime(0.5, SeekMode.Accurate)
          })
      } else {
        Image(this.uri)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius($r('sys.float.corner_radius_level8'))
      }
      Button($r('app.string.camera_picker_button'), { buttonStyle: ButtonStyleMode.NORMAL })
        .backgroundBlurStyle(this.isFilled ? BlurStyle.COMPONENT_REGULAR : BlurStyle.NONE,
          { adaptiveColor: AdaptiveColor.AVERAGE })
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.isFilled ? $r('sys.color.font_on_primary') : $r('sys.color.font_emphasize'))
        .margin({ bottom: $r('sys.float.padding_level10') })
        .onClick(async () => {
          // some device did not have any camera.
          if (this.cameraNum === 0) {
            try {
              promptAction.showToast({ message: $r('app.string.device_camera') });
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
            }
            return;
          }
          try {
            const pickerProfile: cameraPicker.PickerProfile = {
              cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
            };
            const pickerResult: cameraPicker.PickerResult =
              await cameraPicker.pick(getContext(), this.cameraPickerDescriptor.mediaTypes, pickerProfile);
            if (pickerResult.resultCode === CODE_SUCC) {
              this.isFilled = true;
              this.uri = pickerResult.resultUri;
              this.mediaType = pickerResult.mediaType;
            } else {
              Logger.error(TAG, 'the pick pickerResult : error');
            }
          } catch (error) {
            const err = error as BusinessError;
            Logger.error(TAG, `${err.code},${err.message}`);
          }
        })
    }
  }

  getSupportedCameras(cameraManager: camera.CameraManager): camera.CameraDevice[] {
    let cameras: camera.CameraDevice[] = [];
    try {
      cameras = cameraManager.getSupportedCameras();
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `The getSupportedCameras call failed. error code: ${err.code}`);
    }
    return cameras;
  }
}