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

import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class PhotoViewPickerCodeGenerator implements CommonCodeGenerator {
  public generate(_attributes: OriginAttribute[]): string {
    return `import type { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Component
struct PhotoViewPickerComponent {
  @State imageUri: string = '';
  @State imgDatas: string[] = [];
  @State selectedImage: ResourceStr = '';
  @State backBlur: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(this.selectedImage)
        .objectFit(ImageFit.Contain)
        .borderRadius($r('sys.float.corner_radius_level5'))
        .width('100%')
        .height('100%')

      Button('选择图片')
        .buttonStyle(ButtonStyleMode.NORMAL)
        .backgroundBlurStyle(this.backBlur ? BlurStyle.BACKGROUND_THICK : BlurStyle.NONE,
          {
            colorMode: ThemeColorMode.SYSTEM,
            adaptiveColor: AdaptiveColor.DEFAULT,
            scale: 1.0
          })
        .fontColor(this.backBlur ? $r('sys.color.font_on_primary') : $r('sys.color.font_emphasize'))
        .height(40)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .margin({ bottom: 36 })
        .onClick(() => {
          try {
            const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
            photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;
            const photoPicker = new photoAccessHelper.PhotoViewPicker();
            photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
              this.imgDatas = photoSelectResult.photoUris;
              this.imageUri = this.imgDatas[0];
              this.selectedImage = this.imgDatas[0];
              if (this.selectedImage.length > 0) {
                this.backBlur = true;
              }
              console.info(\`PhotoViewPicker.select successfully, PhotoSelectResult uri: \${photoSelectResult.photoUris[0]}\`);

            }).catch((err: BusinessError) => {
              console.info(\`PhotoViewPicker.select failed with err: \${err.code}, \${err.message}\`);
            });
          } catch (error) {
             const err: BusinessError = error as BusinessError;
             console.error(\`PhotoViewPicker failed with err: \${err.code}, \${err.message}\`);
          }
        })
    }
    .width('100%')
  }
}`;
  }
}