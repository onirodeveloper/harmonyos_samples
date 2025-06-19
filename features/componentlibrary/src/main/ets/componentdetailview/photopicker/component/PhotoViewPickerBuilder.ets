/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apach License, Version 2.0 (the "License");
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

import type { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';

const TAG = '[PhotoViewPickerBuilder]';

@Builder
export function PhotoViewPickerBuilder(_$$: DescriptorWrapper) {
  PhotoViewPickerComponent()
}

@Component
struct PhotoViewPickerComponent {
  @State imageUri: string = '';
  @State imgUris: string[] = [];
  @State selectedImageUri: ResourceStr = '';
  @State backBlur: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.selectedImageUri)
        .objectFit(ImageFit.Contain)
        .borderRadius($r('sys.float.corner_radius_level5'))
        .width('100%')
        .height('100%')

      Button($r('app.string.photoViewPicker_text'))
        .buttonStyle(ButtonStyleMode.NORMAL)
        .backgroundBlurStyle(this.backBlur ? BlurStyle.BACKGROUND_THICK : BlurStyle.NONE,
          {
            colorMode: ThemeColorMode.SYSTEM,
            adaptiveColor: AdaptiveColor.DEFAULT,
            scale: DetailPageConstant.SCALE_LEVEL1,
          })
        .fontColor(this.backBlur ? $r('sys.color.font_on_primary') : $r('sys.color.font_emphasize'))
        .height($r('app.float.button_height_normal'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          try {
            const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
            photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;
            const photoPicker = new photoAccessHelper.PhotoViewPicker();
            photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
              this.imgUris = photoSelectResult.photoUris;
              this.imageUri = this.imgUris[0];
              this.selectedImageUri = this.imgUris[0];
              if (this.selectedImageUri.length > 0) {
                this.backBlur = true;
              }
              Logger.info(TAG, `PhotoViewPicker.select successfully}`);
            }).catch((err: BusinessError) => {
              Logger.error(TAG, `PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
            });
          } catch (error) {
            const err: BusinessError = error as BusinessError;
            Logger.error(TAG, `PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
          }
        })
    }
    .width('100%')
  }
}