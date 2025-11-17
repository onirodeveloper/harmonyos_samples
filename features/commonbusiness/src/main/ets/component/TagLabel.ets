/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { TagEnum } from '@ohos/common';

@Component
export struct TagTipLabel {
  tags: number[] = [];
  isSmall: boolean = false;
  newSymbol: Resource = $r('app.media.big_new');

  build() {
    Row() {
      ForEach(this.tags, (item: number) => {
        if (item === TagEnum.NEW) {
          Image(this.newSymbol)
            .objectFit(ImageFit.Contain)
            .size(this.isSmall ? {
              width: $r('app.float.new_tag_width_sm'),
              height: $r('app.float.new_tag_height_sm'),
            } : {
              width: $r('app.float.new_tag_width'),
              height: $r('app.float.new_tag_height'),
            })
        }
      })
    }
  }
}