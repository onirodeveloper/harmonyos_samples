/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { ImageKnifeComponent, ImageKnifeOption } from '@ohos/imageknife';
import { CommonConstants } from '../constant/CommonConstants';
import { ImageKnifeUtil } from '../util/ImageKnifeUtil';
import { ImageUtil } from '../util/ImageUtil';
import { UrlUtil } from '../util/UrlUtil';

@Reusable
@Component
export struct ImageComponent {
  @Prop @Require @Watch('handleSrcChange') src: string;
  @Prop objectFit: ImageFit = ImageFit.Contain;
  @Prop alt: ResourceStr = $r('app.media.ic_placeholder');
  @State imageOption?: ImageKnifeOption = undefined;
  @State isLoaded: boolean = false;

  aboutToAppear(): void {
    this.handleSrcChange();
  }

  aboutToReuse(params: Record<string, Object | null | undefined>): void {
    this.src = params.src as string;
    this.objectFit = (params.objectFit as ImageFit) ?? ImageFit.Contain;
    this.alt = (params.alt as ResourceStr) ?? $r('app.media.ic_placeholder');
    this.handleSrcChange();
  }

  handleSrcChange() {
    const options = ImageKnifeUtil.getImgOption(this.src);
    options.objectFit = this.objectFit;
    options.placeholderSrc = this.alt;
    this.imageOption = options;
  }

  build() {
    if (UrlUtil.isNetUrl(this.src)) {
      ImageKnifeComponent({
        imageKnifeOption: this.imageOption,
      })
        .draggable(false)
    } else {
      Image(ImageUtil.getImgResource(this.src))
        .alt(this.alt)
        .objectFit(this.objectFit)
        .draggable(false)
        .opacity(this.isLoaded ? 1 : 0)
        .animation({
          duration: CommonConstants.ANIMATION_DURATION,
          curve: Curve.EaseIn
        })
        .onComplete(() => {
          this.isLoaded = true;
        })
    }
  }
}