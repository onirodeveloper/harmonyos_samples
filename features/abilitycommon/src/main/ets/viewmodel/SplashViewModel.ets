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

import { BaseVM, CommonConstants, Logger, PageContext, PageEnum, PreferenceManager, StorageKey } from '@ohos/common';
import { DiscoverModel } from '@ohos/exploration';
import { ComponentListModel } from '@ohos/componentlibrary';
import { SampleModel } from '@ohos/devpractices';
import { SplashModel } from '../model/SplashModel';

const TAG: string = '[SplashViewModel]';
// Version number of the guidance. If new version needs to display guidance carousel, change this value.
const SPLASH_VERSION: number = 1;

export class SplashViewModel extends BaseVM<SplashModel> {
  private componentListModel: ComponentListModel = ComponentListModel.getInstance();
  private sampleModel: SampleModel = SampleModel.getInstance();
  private discoverModel: DiscoverModel = DiscoverModel.getInstance();
  public swiperController: SwiperController = new SwiperController();
  private intervalId?: number;
  private static instance: SplashViewModel;

  private constructor() {
    super(new SplashModel());
    this.state.splashSource.setDataArray([
      $r('app.media.ic_splash_1_lg'),
      $r('app.media.ic_splash_2'),
      $r('app.media.ic_splash_3'),
      $r('app.media.ic_splash_4'),
    ]);
  }

  public static getInstance(): SplashViewModel {
    if (!SplashViewModel.instance) {
      SplashViewModel.instance = new SplashViewModel();
    }
    return SplashViewModel.instance;
  }

  public sendEvent<T>(eventParam: SplashEventParam<T>): void {
    if (eventParam.type === SplashEventTypeEnum.JUMP_TO_MAIN) {
      return this.jumpToMainPage();
    } else if (eventParam.type === SplashEventTypeEnum.PRELOAD_RESOURCES) {
      return this.preloadResources();
    } else if (eventParam.type === SplashEventTypeEnum.CHECK_FIRST_START) {
      this.checkIsFirstStart();
    } else if (eventParam.type === SplashEventTypeEnum.UPDATE_START_VERSION) {
      this.updateStartVersion();
    } else if (eventParam.type === SplashEventTypeEnum.CLEAR_INTERVAL) {
      this.clearInterval();
    }
  }

  private jumpToMainPage(): void {
    this.clearInterval();
    this.updateStartVersion();
    AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT)?.replacePage({
      routerName: PageEnum.MAIN_PAGE,
    }, false);
  }

  private preloadResources(): void {
    this.componentListModel.preloadComponentData();
    this.sampleModel.preloadSamplePageData()
    this.discoverModel.preloadDiscoveryData()
  }

  private updateStartVersion(): void {
    PreferenceManager.getInstance().setValue('firstStartVersion', SPLASH_VERSION);
  }

  private checkIsFirstStart(): void {
    this.state.showSwiper = false;
    const hasResult: boolean = PreferenceManager.getInstance().hasValue('firstStartVersion');
    let firstStart: boolean = !hasResult;
    if (hasResult) {
      Logger.info(TAG, 'Not first startup.');
      const splashVersion = PreferenceManager.getInstance().getValue<number>('firstStartVersion');
      firstStart = splashVersion !== SPLASH_VERSION;
    }
    this.state.showSwiper = firstStart;
    if (!firstStart) {
      const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
      if (!uiContext) {
        Logger.error(TAG, 'startAnimation failed cause uiContext is null or undefined');
        this.preloadResources();
        this.jumpToMainPage();
      } else {
        uiContext?.animateTo({
          duration: CommonConstants.ANIMATION_DURATION,
          onFinish: () => {
            this.jumpToMainPage();
          }
        }, () => {
          this.preloadResources();
        });
      }
    } else {
      this.showSplashSwiper();
    }
  }

  showSplashSwiper() {
    this.state.showSwiper = true;
    this.intervalId = setInterval(() => {
      this.state.durationTime--;
      if (this.state.durationTime % 3 === 0) {
        this.swiperController.showNext();
      }
      if (this.state.durationTime <= 0) {
        this.clearInterval();
        this.updateStartVersion();
      }
    }, 1000);
  }

  clearInterval() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
  }
}

export interface SplashEventParam<T> {
  type: SplashEventTypeEnum,
  param?: T,
}

export enum SplashEventTypeEnum {
  JUMP_TO_MAIN = 'jumpToMainPage',
  PRELOAD_RESOURCES = 'preloadResources',
  CHECK_FIRST_START = 'checkIsFirstStart',
  UPDATE_START_VERSION = 'updateStartVersion',
  CLEAR_INTERVAL = 'clearInterval',
}