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

import { common } from '@kit.AbilityKit';
import { ArcSwiper, ArcSwiperController } from '@kit.ArkUI';
import { ProcessUtil } from '@ohos/common';
import { HomePageComponent } from '../component/HomepageComponent';
import { SampleListView } from '../view/SampleListView';

@Component
struct MainPage {
  private wearableSwiperController: ArcSwiperController = new ArcSwiperController();
  private currentIndex: number = 0;

  build() {
    NavDestination() {
      ArcSwiper(this.wearableSwiperController) {
        HomePageComponent()
          .onClick(() => {
            this.wearableSwiperController.showNext();
          })
        SampleListView()
      }
      .indicator(false)
      .onDigitalCrown((event: CrownEvent) => {
        event.stopPropagation();
      })
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .onAnimationStart((index: number, targetIndex: number, event: SwiperAnimationEvent) => {
        if (index === 0 && targetIndex === 0 && event.currentOffset > 0) {
          ProcessUtil.moveAbilityToBackground(this.getUIContext().getHostContext() as common.UIAbilityContext);
        }
      })
    }
    .onBackPressed(() => {
      if (this.currentIndex === 0) {
        ProcessUtil.moveAbilityToBackground(this.getUIContext().getHostContext() as common.UIAbilityContext);
      } else {
        this.wearableSwiperController.showPrevious();
      }
      return true;
    })
    .backgroundColor(Color.Black)
    .transition(TransitionEffect.OPACITY)
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
  }
}

@Builder
export function MainPageBuilder() {
  MainPage()
}