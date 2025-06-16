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

export class AIImageCodeGenerator implements CommonCodeGenerator {
  public generate(_attributes: OriginAttribute[]): string {
    return `import { image } from '@kit.ImageKit';

@Component
export struct AIImageComponent {
  @State imagePixelMap?: image.PixelMap = undefined;

  async aboutToAppear() {
    // 图片资源替换项目src/main/resources/base/media路径下资源
    this.imagePixelMap = await this.getPixmapFromMedia($r("app.media.image_ai"));
  }

  aboutToDisappear(): void {
    this.imagePixelMap?.release();
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 图片资源替换项目src/main/resources/base/media路径下资源
        Image(this.imagePixelMap ?? $r("app.media.image_ai"))
          .enableAnalyzer(true)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius($r('sys.float.corner_radius_level8'))
          .draggable(false)
      }
      .width('80%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  private async getPixmapFromMedia(resource: Resource) {
    let createPixelMap: image.PixelMap;
    try {
      const unit8Array = await getContext(this)?.resourceManager?.getMediaContent({
        bundleName: resource.bundleName,
        moduleName: resource.moduleName,
        id: resource.id,
      });
      const imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
      createPixelMap = await imageSource.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
      });
      await imageSource.release();
      this.imagePixelMap?.release();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      console.error(\`Get pixmapFromMedia error, the code is \${error.code}, the message is \${error.message}\`);
      return;
    }
    return createPixelMap;
  }
}`
  }
}