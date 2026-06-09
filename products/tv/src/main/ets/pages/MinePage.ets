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

import {
  HdsNavigation,
  HdsNavigationTitleMode,
  ScrollEffectType,
  hdsMaterial
} from '@kit.UIDesignKit';
import {
  CommonConstants, HmosListItem,
  LoginSheetViewBuilder,
  PageContext, PageEnum, StorageKey,
} from '@ohos/common';
import { MinePageState } from '../viewmodel/MinePageState';
import { LoginEvent, LogoutEvent, MinePageEvent, MinePageVM,
  UpdateAccountStatusEvent } from '../viewmodel/MineViewModel';
import { ComponentContent } from '@kit.ArkUI';

@Builder
function defaultPlaceholder() {
  Column() {}
  .width(CommonConstants.FULL_PERCENT)
  .height(CommonConstants.FULL_PERCENT)
  .backgroundColor($r('sys.color.background_tertiary'))
}

@Component
export struct MineView {
  @StorageLink(StorageKey.MINE_PAGE_CONTEXT) minePageContext: PageContext =
    AppStorage.get<PageContext>(StorageKey.MINE_PAGE_CONTEXT) ?? new PageContext();
  @State viewModel: MinePageVM = MinePageVM.getInstance();
  @State minePageState: MinePageState = this.viewModel.getState();

  @Builder
  accountArea() {
    Row() {
      if (this.minePageState.isLogin) {
        if (this.minePageState.avatarUrl !== '') {
          Image(this.minePageState.avatarUrl)
            .draggable(false)
            .width($r('app.float.mine_image_size'))
            .height($r('app.float.mine_image_size'))
            .borderRadius($r('sys.float.corner_radius_level12'))
        } else {
          Text(this.minePageState.nickName.slice(-1))
            .width($r('app.float.mine_image_size'))
            .height($r('app.float.mine_image_size'))
            .borderRadius($r('sys.float.corner_radius_level12'))
            .backgroundColor($r('sys.color.ohos_id_color_tertiary'))
            .linearGradient({
              colors: [
                [$r('sys.color.ohos_id_color_tertiary'), 0.0],
                [$r('sys.color.ohos_id_color_foreground_contrary'), 1.0],
              ],
            })
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
        }
        Text(this.minePageState.nickName)
          .margin({ left: $r('sys.float.padding_level8') })
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontFamily('HarmonyOS Heiti')
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Start)
          .margin({ left: $r('sys.float.padding_level6') })
      } else {
        SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
          .fontSize($r('sys.float.Display_L'))
          .fontColor([$r('sys.color.icon_fourth')])
        Text($r('app.string.login_with_huawei_account'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: $r('sys.float.padding_level6') })
      }
    }
    .hoverEffect(HoverEffect.Auto)
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_tertiary'))
    .padding($r('sys.float.padding_level6'))
    .bindSheet(this.minePageState.isShowAccountInfo, this.LoginSheetViewBuilder(), {
      height: SheetSize.MEDIUM,
      preferType: SheetType.CENTER,
      hoverModeArea: HoverModeAreaType.BOTTOM_SCREEN,
      enableOutsideInteractive: false,
      blurStyle: BlurStyle.Regular,
      onWillDisappear: () => {
        this.viewModel.sendEvent(new UpdateAccountStatusEvent());
      },
    })
    .onClick(() => {
      if (!this.minePageState.isLogin) {
        this.viewModel.sendEvent(new LoginEvent(this.getUIContext()));
      } else {
        this.viewModel.sendEvent(new LogoutEvent(this.getUIContext()));
      }
    })
  }

  @Builder
  contentViewBuilder() {
    Scroll(new Scroller()) {
      Column({ space: CommonConstants.SPACE_12 }) {
        this.accountArea()
        HmosListItem({
          prefixResource: $r('sys.symbol.gearshape'),
          title: $r('app.string.setting'),
          handleClickAction: () => {
            this.viewModel.sendEvent(new MinePageEvent(PageEnum.TV_SETTINGS_VIEW))
          }
        })
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.tv_mine_listitem_height'))
        HmosListItem({
          prefixResource: $r('sys.symbol.code_1'),
          title: $r('app.string.view_source'),
          handleClickAction: () => {
            this.viewModel.sendEvent(new MinePageEvent(PageEnum.TV_SOURCECODE_VIEW))
          }
        })
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.tv_mine_listitem_height'))
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor($r('sys.color.background_primary'))
    .align(Alignment.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({
      top: $r('app.float.tv_mine_padding_top'),
      left: $r('app.float.tv_mine_padding_left_right'),
      right: $r('app.float.tv_mine_padding_left_right'),
    })
  }

  @Builder
  LoginSheetViewBuilder() {
    LoginSheetViewBuilder({
      nickname: this.minePageState.nickName,
      avatarUrl: this.minePageState.avatarUrl,
      unionId: ' ',
    })
  }

  build() {
    WithTheme({ colorMode: ThemeColorMode.DARK }) {
      HdsNavigation(this.minePageContext.navPathStack) {
        this.contentViewBuilder();
      }
      .titleBar({
        style: {
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.IMMERSIVE,
            materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
          },
          scrollEffectOpts: {
            enableScrollEffect: true,
            scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
              ScrollEffectType.COMMON_BLUR,
          },
        },
        content: {
          title: { mainTitle: $r('app.string.mine_title') },
        },
        avoidLayoutSafeArea: true
      })
      .navBarWidth(CommonConstants.TV_MINEPAGE_NAVBAR_WIDTH)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .defaultFocus(true)
      .hideBackButton(true)
      .mode(NavigationMode.Split)
      .titleMode(HdsNavigationTitleMode.MODAL)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
      .splitPlaceholder(new ComponentContent(this.getUIContext(), wrapBuilder(defaultPlaceholder)))
    }
  }
}