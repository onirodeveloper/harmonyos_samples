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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import { emitter } from '@kit.BasicServicesKit';
import { GlobalInfoModel, TrackEventType, TrackManager, TrackServiceData } from '@ohos/common';
import {
  CommonConstants,
  LoadingStatus,
  StorageKey,
  Toast,
  TopNavigationView,
  VersionUtil,
  WindowUtil,
} from '@ohos/common';
import { BaseDetailComponent, CardTypeEnum, SampleDetailParams } from '@ohos/commonbusiness';
import { SampleComponent } from '../component/SampleComponent';
import type { SampleDetailData, SampleDetailState } from '../viewmodel/SampleDetailState';
import {
  AssignPathStackEvent,
  InitSampleDetailEvent,
  PopEvent,
  SampleDetailPageVM,
  SetIndexEvent,
} from '../viewmodel/SampleDetailPageVM';

@Builder
export function SampleDetailViewBuilder() {
  SampleDetailView()
}

@Component
export struct SampleDetailView {
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  viewModel: SampleDetailPageVM = SampleDetailPageVM.getInstance();
  @State sampleDetailState: SampleDetailState = this.viewModel.getState();
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;
  @Provide currentIndex: number = -1;
  private sampleId: number = 0;
  private cardId: number = 0;
  private unionId?: number = 0;
  private contentType: CardTypeEnum = CardTypeEnum.SAMPLE;

  aboutToAppear(): void {
    this.handleColorModeChange();
  }

  handleColorModeChange() {
    const isSystemDark: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    WindowUtil.updateStatusBarColor(isSystemDark);
  }

  handleOnReady(cxt: NavDestinationContext) {
    const params = cxt?.pathInfo?.param as SampleDetailParams;
    this.sampleId = params.id;
    this.cardId = params.cardId;
    this.unionId = params.unionId;
    this.currentIndex = params.currentIndex;
    this.contentType = params.contentType;
    this.viewModel.sendEvent(new InitSampleDetailEvent(this.sampleId, this.cardId, params.currentIndex,
      params.unionId));
    this.viewModel.sendEvent(new AssignPathStackEvent(cxt?.pathStack));
  }

  @Builder
  SampleDetailBuilder() {
    Swiper() {
      ForEach(this.sampleDetailState.sampleDatas, (item: SampleDetailData, index: number) => {
        SampleComponent({
          singleSampleData: item,
          sampleIndex: index,
          showIndicator: this.sampleDetailState.sampleCount > 1,
          widthBreakpoint: this.globalInfoModel.widthBreakpoint,
          contentType: this.contentType,
        })
      }, (item: SampleDetailData) => item.id.toString())
    }
    .layoutWeight(1)
    .width('100%')
    .padding({
      top: CommonConstants.NAVIGATION_HEIGHT + (VersionUtil.canUseHds() ? this.globalInfoModel.statusBarHeight : 0),
      bottom: this.globalInfoModel.naviIndicatorHeight,
    })
    .indicator(this.sampleDetailState.sampleCount > 1)
    .index(this.currentIndex)
    .disableSwipe(this.sampleDetailState.sampleCount === 1 || this.sampleDetailState.installingStatus ||
    this.sampleDetailState.downloadingStatus)
    .onChange((index: number) => {
      this.viewModel.sendEvent(new SetIndexEvent(index));
      this.currentIndex = index;
      TrackManager.getInstance().reportData({
        content: this.sampleDetailState.sampleDatas[index].sampleCard.title,
        moduleType: this.contentType,
        eventType: TrackEventType.SAMPLE_CLICK,
      } as TrackServiceData)
    })
    .gesture(
      SwipeGesture({ direction: SwipeDirection.Horizontal })
        .onAction(() => {
          if (this.sampleDetailState.sampleDatas[this.currentIndex].sampleCard.downloadProgress >= 0 &&
            this.sampleDetailState.sampleCount > 1) {
            Toast.showToast($r('app.string.swiper_gesture'));
          }
        })
    )
  }

  @Builder
  TopTitleViewBuilder() {
    TopNavigationView({
      topNavigationData: {
        title: $r('app.string.sample_title'),
        onBackClick: () => {
          this.onBack();
        },
      },
      menuView: () => {
        this.TopNavigationMenu();
      }
    })
  }

  @Builder
  DetailContentBuilder() {
    BaseDetailComponent({
      detailContentView: () => {
        this.SampleDetailBuilder()
      },
      topTitleView: () => {
        if (!VersionUtil.canUseHds()) {
          this.TopTitleViewBuilder()
        }
      },
      loadingStatus: this.sampleDetailState.loadingStatus,
      reloadData: () => {
        this.viewModel.sendEvent(new InitSampleDetailEvent(this.sampleId, this.cardId, this.currentIndex,
          this.unionId));
      }
    })
  }

  @Builder
  TopNavigationMenu() {
    Button() {
      SymbolGlyph($r('sys.symbol.square_and_pencil'))
        .fontColor([$r('sys.color.icon_primary')])
        .fontSize($r('sys.float.Title_M'))
    }
    .width($r('app.float.feedback_sheet_button_size'))
    .height($r('app.float.feedback_sheet_button_size'))
    .aspectRatio(1)
    .backgroundColor(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? Color.Transparent :
      $r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      emitter.emit(CommonConstants.BIND_SHEET_OPEN_EVENT + this.currentIndex);
    })
    .margin({
      right: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        $r('app.float.feedback_right_padding_xl') : 0
    })
  }

  build() {
    if (VersionUtil.canUseHds()) {
      HdsNavDestination() {
        this.DetailContentBuilder();
      }
      .hideBackButton(false)
      .titleBar({
        avoidLayoutSafeArea: true,
        style: {
          originalStyle: { backgroundStyle: { backgroundColor: Color.Transparent } },
          scrollEffectOpts: {
            enableScrollEffect: false,
          },
        },
        content: {
          title: { mainTitle: $r('app.string.sample_title') },
          menu: {
            value: [{
              content: {
                icon: $r('sys.symbol.square_and_pencil'),
                isEnabled: true,
                action: () => {
                  emitter.emit(CommonConstants.BIND_SHEET_OPEN_EVENT + this.currentIndex);
                }
              }
            }]
          },
        }
      })
      .backgroundColor($r('sys.color.background_secondary'))
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
      .onReady((cxt: NavDestinationContext) => this.handleOnReady(cxt))
      .onBackPressed(() => {
        return this.onBack();
      })
      .onWillShow(() => {
        this.sampleDetailState.isBackPressed = false;
      })
      .onWillHide(() => {
        this.sampleDetailState.isBackPressed = false;
      })
    } else {
      NavDestination() {
        this.DetailContentBuilder()
      }
      .onReady((cxt: NavDestinationContext) => this.handleOnReady(cxt))
      .onBackPressed(() => {
        return this.onBack();
      })
      .onWillShow(() => {
        this.sampleDetailState.isBackPressed = false;
      })
      .onWillHide(() => {
        this.sampleDetailState.isBackPressed = false;
      })
      .padding({ top: this.globalInfoModel.statusBarHeight })
      .hideTitleBar(true)
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }

  private onBack(): boolean {
    if (!this.sampleDetailState.isBackPressed) {
      this.viewModel.sendEvent(new PopEvent());
    }
    return true;
  }
}