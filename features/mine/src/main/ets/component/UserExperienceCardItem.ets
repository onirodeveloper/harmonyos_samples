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

import { CommonConstants, GlobalInfoModel, StorageKey } from '@ohos/common';

@Component
export struct UserExperienceCardItem {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @BuilderParam contentView: () => void = this.defaultBuilder;
  textContent?: ResourceStr;
  subTextContent?: ResourceStr;
  imageSrc?: Resource;
  onclick?: Function;

  @Builder
  defaultBuilder() {
  }

  @Styles
  pressedStyle() {
    .backgroundColor($r('sys.color.comp_background_secondary'))
  }

  @Styles
  normalStyles(): void {
    .backgroundColor('sys.color.comp_background_primary')
  }

  build() {
    Row() {
      Column() {
        Text(this.textContent)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Text(this.subTextContent)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ top: $r('sys.float.padding_level1') })
      }
      .alignItems(HorizontalAlign.Start)
      .padding($r('sys.float.padding_level6'))

      Blank()
      Image($r('app.media.userExperience'))
        .height($r('app.float.user_experience_size'))
        .aspectRatio(1)
    }
    .hoverEffect(HoverEffect.Highlight)
    .stateStyles({
      pressed: this.pressedStyle,
      normal: this.normalStyles,
    })
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.mine_listItem_height_large'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .onClick(() => {
      if (this.onclick) {
        this.onclick();
      }
    })
  }
}