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

import type { BundleInfoData } from '@ohos/common';
import type { AboutState } from '../viewmodel/AboutState';
import { AboutVM, CheckVersionEvent, UpdateVersionEvent } from '../viewmodel/AboutVM';

@Component
export struct AboutItemCard {
  viewModel: AboutVM = AboutVM.getInstance();
  @State aboutState: AboutState = this.viewModel.getState();

  aboutToAppear(): void {
    this.viewModel.sendEvent(new CheckVersionEvent());
  }

  build() {
    Row() {
      Column() {
        if (this.aboutState.laterVersionExist) {
          Badge({
            value: '',
            style: { badgeSize: 6, badgeColor: $r('app.color.about_badge_color') },
            position: BadgePosition.Right,
          }) {
            Text($r('app.string.version_information'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ right: $r('sys.float.padding_level6') })
          }
        } else {
          Text($r('app.string.version_information'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
        }

        Text(AppStorage.get<BundleInfoData>('BundleInfoData')?.versionName as string)
          .margin({ top: $r('sys.float.padding_level2') })
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      Row() {
        if (!this.aboutState.isLoadingUpdate) {
          Text(this.aboutState.laterVersionExist ? $r('app.string.updated_version') : $r('app.string.latest_version'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Subtitle_S'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ right: $r('sys.float.padding_level2') })
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize($r('sys.float.Title_S'))
            .fontColor([$r('sys.color.icon_fourth')])
        } else {
          LoadingProgress()
            .width($r('app.float.about_loadingProgress_size'))
            .height($r('app.float.about_loadingProgress_size'))
        }
      }
      .onClick(() => {
        if (this.aboutState.laterVersionExist) {
          this.viewModel.sendEvent(new UpdateVersionEvent());
        }
      })
    }
    .width('100%')
    .height($r('app.float.about_item_card_height'))
    .borderRadius($r('sys.float.corner_radius_level7'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('sys.float.padding_level6'),
      top: $r('sys.float.padding_level7'),
      bottom: $r('sys.float.padding_level7'),
      right: $r('sys.float.padding_level6'),
    })
  }
}