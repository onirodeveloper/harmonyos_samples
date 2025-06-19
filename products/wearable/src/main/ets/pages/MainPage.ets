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

import { ArcSwiper, ArcSwiperAttribute, ArcSwiperController } from '@kit.ArkUI';
import { MockRequest } from '@ohos/common';
import { HomePageComponent } from '../component/HomepageComponent';
import { SampleListComponent } from '../component/SampleListComponent';
import { WearableSampleData } from '../model/WearableSampleData';

const WEARABLE_SAMPLE_TRIGGER: string = 'wearable-sample-list';

@Entry
@Component
struct MainPage {
  private wearableSwiperController: ArcSwiperController = new ArcSwiperController();
  private wearableSampleList: WearableSampleData[] = [];

  aboutToAppear(): void {
    MockRequest.call<WearableSampleData[]>(WEARABLE_SAMPLE_TRIGGER)
      .then((result: WearableSampleData[]) => {
        this.wearableSampleList = result;
      })
  }

  build() {
    ArcSwiper(this.wearableSwiperController) {
      HomePageComponent()
        .onClick(() => {
          this.wearableSwiperController.showNext();
        })
      SampleListComponent({ wearableSampleList: this.wearableSampleList })
    }
    .indicator(false)
    .onDigitalCrown((event: CrownEvent) => {
      event.stopPropagation();
    })
  }
}