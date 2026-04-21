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
import { HdsNavigation } from '@kit.UIDesignKit';
import {
  BreakpointType,
  BundleInfoData,
  CommonConstants,
  GlobalInfoModel,
  ImageKnifeUtil,
  Logger,
  PageContext,
  ResourceUtil,
  StorageKey,
  WindowUtil,
} from '@ohos/common';
import { SplashModel } from '../model/SplashModel';
import { SplashEventTypeEnum, SplashViewModel } from '../viewmodel/SplashViewModel';

const TAG: string = '[SplashPage]';

@Entry
@Component
struct SplashPage {
  context: Context = this.getUIContext().getHostContext() as Context;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = new GlobalInfoModel();
  @StorageProp(StorageKey.BUNDLE_INFO) @Watch('updateIcon') bundleInfo?: BundleInfoData =
    AppStorage.get(StorageKey.BUNDLE_INFO);
  @StorageLink(StorageKey.HOME_PAGE_CONTEXT) pageContext: PageContext =
    AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT) ?? new PageContext();
  @Provide('appIconDescriptor') drawableDescriptor?: DrawableDescriptor = undefined;
  private appPathInfo: NavPathStack = this.pageContext?.navPathStack;
  private viewModel: SplashViewModel = SplashViewModel.getInstance();
  @State splashState: SplashModel = this.viewModel.getState();
  @State currentIndex: number = 0;

  onPageHide() {
    Logger.info(TAG, 'onPageHide');
    const isSystemDark: boolean =
      AppStorage.get(StorageKey.COLOR_MODE) === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    WindowUtil.updateStatusBarColor(isSystemDark);
  }

  async aboutToAppear(): Promise<void> {
    WindowUtil.updateStatusBarColor(true);
    await ImageKnifeUtil.initialize(this.context);
    this.viewModel.sendEvent<null>({ type: SplashEventTypeEnum.CHECK_FIRST_START });
    this.updateIcon();
  }

  aboutToDisappear(): void {
    this.viewModel.sendEvent<null>({ type: SplashEventTypeEnum.CLEAR_INTERVAL });
    Logger.info(TAG, `SplashPage about to disappear.`)
  }

  updateIcon() {
    this.drawableDescriptor =
      ResourceUtil.getDrawableDescriptor(this.context, this.bundleInfo?.iconResource?.id);
  }

  @Builder
  contentBuilder() {
    RelativeContainer() {
      if (this.splashState.showSwiper) {
        Swiper(this.viewModel.swiperController) {
          LazyForEach(this.splashState.splashSource, (src: Resource, index: number) => {
            SplashImgItem({
              imgSrc: index === 0 ? new BreakpointType({
                sm: $r('app.media.ic_splash_1_sm'),
                md: $r('app.media.ic_splash_1_md'),
                lg: $r('app.media.ic_splash_1_lg')
              }).getValue(this.globalInfoModel.widthBreakpoint) : src,
              index,
              handleClickAction: () => {
                this.viewModel.sendEvent<null>({ type: SplashEventTypeEnum.JUMP_TO_MAIN });
              },
            })
          }, (_item: Resource, index: number) => index.toString())
        }
        .cachedCount(this.splashState.splashSource.totalCount())
        .effectMode(EdgeEffect.None)
        .loop(false)
        .autoPlay(false)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .indicator(new DotIndicator()
          .bottom(this.globalInfoModel.naviIndicatorHeight)
        )
        .onGestureSwipe(() => {
          this.viewModel.sendEvent<null>({ type: SplashEventTypeEnum.UPDATE_START_VERSION });
        })

        Button($r('app.string.skip', this.splashState.durationTime),
          { buttonStyle: ButtonStyleMode.NORMAL, controlSize: ControlSize.SMALL })
          .margin({
            top: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? CommonConstants.SPACE_48 :
              this.globalInfoModel.statusBarHeight + CommonConstants.SPACE_16,
            right: $r('sys.float.padding_level8')
          })
          .fontColor($r('sys.color.font_on_primary'))
          .width($r('app.float.skip_button_width'))
          .visibility((this.splashState.showSwiper && this.splashState.durationTime > 0) ? Visibility.Visible :
            Visibility.None)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            right: { anchor: '__container__', align: HorizontalAlign.End },
          })
          .onClick(() => {
            this.viewModel.sendEvent<null>({ type: SplashEventTypeEnum.JUMP_TO_MAIN });
          })
      }
    }
    .id('_container_')
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
  }

  build() {
    HdsNavigation(this.appPathInfo) {
      this.contentBuilder()
    }
    .hideTitleBar(true)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
  }
}

@Reusable
@Component
struct SplashImgItem {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = new GlobalInfoModel();
  @Prop imgSrc: Resource;
  @Prop index: number;
  handleClickAction?: () => void;

  aboutToReuse(params: Record<string, Resource | number>): void {
    this.imgSrc = params.imgSrc as Resource;
    this.index = params.index as number;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(this.imgSrc)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Button($r('app.string.experience_now'))
        .margin({
          bottom: this.globalInfoModel.naviIndicatorHeight + CommonConstants.SPACE_32,
        })
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .borderColor($r('sys.color.background_emphasize'))
        .borderWidth(1)
        .fontColor($r('sys.color.font_emphasize'))
        .width($r('app.float.experience_button_width'))
        .visibility(this.index === 3 ? Visibility.Visible : Visibility.None)
        .onClick(() => this.handleClickAction?.())
    }
  }
}