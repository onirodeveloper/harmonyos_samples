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

import { HmosListItem } from '@ohos/common';

@Component
struct SettingView {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      List() {
        ListItemGroup() {
          ListItem() {
            HmosListItem({
              title: $r('app.string.about'),
              handleClickAction: () => {
                this.pathStack.pushPath({ name: 'AboutView' });
              }
            })
          }
          .padding({ left: $r('sys.float.padding_level2'), right: $r('sys.float.padding_level2') })
        }
        .divider({
          strokeWidth: $r('app.float.mine_divider'),
          color: $r('sys.color.comp_divider'),
          startMargin: $r('sys.float.padding_level6'),
          endMargin: $r('sys.float.padding_level6'),
        })
        .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius($r('sys.float.corner_radius_level8'))
      }
      .padding($r('sys.float.padding_level8'))
      .height('100%')
      .width('100%')
      .clipContent(ContentClipMode.SAFE_AREA)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideBackButton(true)
    .title($r('app.string.setting'))
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: $r('sys.float.padding_level4') })
    .mode(NavigationMode.Stack)
  }
}

@Builder
export function SettingViewBuilder() {
  SettingView()
}