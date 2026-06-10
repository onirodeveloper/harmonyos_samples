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

import { CommonConstants, Logger, ProcessUtil } from '@ohos/common';
import { common } from '@kit.AbilityKit';
import { HdsNavDestination, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import { HomeContent } from '../component/HomeContent';
import { BarItemData, BarItemType } from '../model/BarItemData';
import { BarComponent } from '../component/BarComponent';
import { MineView } from './MinePage';
import { MainViewModel } from '../viewmodel/MainViewModel';
import { KeyCode } from '@kit.InputKit';

const TAG: string = '[MainPage]';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State viewModel: MainViewModel = MainViewModel.getInstance();
  private barItemDataList: BarItemData[] = [
    {
      barItemType: BarItemType.TEXT,
      title: $r('app.string.sample'),
    },
    {
      barItemType: BarItemType.SYMBOL,
      uri: $r('sys.symbol.person_fill'),
    }
  ]
  private tabController: HdsTabsController = new HdsTabsController();

  @Builder
  TabContentsBuilder() {
    TabContent() {
      HomeContent()
    }

    TabContent() {
      MineView()
    }
  }

  aboutToAppear(): void {
    Logger.info(TAG, 'MainPage aboutToAppear');
  }

  onBackPress(): boolean {
    ProcessUtil.moveAbilityToBackground(this.getUIContext().getHostContext() as common.UIAbilityContext);
    return true;
  }

  build() {
    HdsNavDestination() {
      Stack() {
        HdsTabs({ controller: this.tabController, index: this.currentIndex }) {
          this.TabContentsBuilder()
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .scrollable(false)

        BarComponent({ barItemDataList: this.barItemDataList, currentIndex: this.currentIndex })
          .padding({
            right: $r('app.float.main_page_bar_right_padding'),
            top: $r('app.float.main_page_bar_top_padding')
          })

      }
      .alignContent(Alignment.TopEnd)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .onBackPressed(() => {
      return this.onBackPress();
    })
  }
}

@Builder
export function MainPageBuilder() {
  MainPage()
}
