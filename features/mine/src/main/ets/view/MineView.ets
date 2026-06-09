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

import { emitter } from '@kit.BasicServicesKit';
import {
  TitleBarStyleOptions,
  ScrollEffectType,
  hdsMaterial,
  HdsNavDestination,
  HdsTabsController,
} from '@kit.UIDesignKit';
import {
  AccountService,
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  HdsUtil,
  HmosListItem,
  LoginSheetViewBuilder,
  StorageKey,
} from '@ohos/common';
import { BaseHomeEventType, HomeListParams } from '@ohos/commonbusiness';
import { MineEventType, MinePageVM, } from '../viewmodel/MinePageVM';
import { BuilderEnum, ListGroup, MineItem, MinePageState } from '../viewmodel/MinePageState';
import { UserExperienceCardItem } from '../component/UserExperienceCardItem';
import { MineConstant } from '../constant/CommonConstants';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct MineView {
  @State viewModel: MinePageVM = MinePageVM.getInstance();
  @State minePageState: MinePageState = this.viewModel.getState();
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State bindSheetShow: boolean = false;
  @State bindSheetItem?: MineItem = undefined;
  @State titleBarStyle: TitleBarStyleOptions = {
    scrollEffectOpts: {
      scrollEffectType: ScrollEffectType.COMMON_BLUR,
      enableScrollEffect: true,
    },
  };
  homeTabController: HdsTabsController = new HdsTabsController();
  scroller: Scroller = new Scroller();

  throttle(func: Function, interval: number) {
    let lastTime = 0;
    return () => {
      const nowTime = Date.now();
      const remainTime = interval - (nowTime - lastTime);
      if (remainTime <= 0) {
        lastTime = nowTime;
        func();
      }
    };
  }

  async aboutToAppear(): Promise<void> {
    if (HdsUtil.isSupportNewMaterialApi()) {
      this.titleBarStyle = {
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
            ScrollEffectType.COMMON_BLUR,
        },
      }
    }
    AccountService.getInstance().init();
    this.viewModel.sendEvent<null>({ type: MineEventType.INIT_DATA, param: null });
    this.viewModel.sendEvent<null>({ type: MineEventType.LOAD_CONTENT_NUMBER, param: null });
    emitter.on(CommonConstants.BIND_SHEET_CLOSE_EVENT, () => {
      this.bindSheetShow = false;
    });
    emitter.on(CommonConstants.BIND_LOGOUT_EVENT, () => {
      this.viewModel.sendEvent({
        type: MineEventType.UPDATE_ACCOUNT_DATA,
        param: null,
      });
    });
    emitter.on(CommonConstants.BIND_MINE_LOGIN_EVENT, () => {
      this.viewModel.sendEvent<null>({ type: MineEventType.UPDATE_ACCOUNT_DATA, param: null });
    });
  }

  aboutToDisappear(): void {
    emitter.off(CommonConstants.BIND_SHEET_CLOSE_EVENT);
    emitter.off(CommonConstants.BIND_LOGOUT_EVENT);
    emitter.off(CommonConstants.BIND_MINE_LOGIN_EVENT);
  }

  @Builder
  itemHead() {
    ListItem({ style: ListItemStyle.CARD }) {
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
            .fontSize($r('sys.float.ohos_id_text_size_headline9'))
            .fontFamily('HarmonyOS Heiti')
            .fontWeight(FontWeight.Medium)
            .align(Alignment.Start)
        } else {
          SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
            .fontSize($r('sys.float.Display_L'))
            .fontColor([$r('sys.color.icon_fourth')])
          Text($r('app.string.unregistered_title'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ left: $r('sys.float.padding_level6') })
        }
      }
      .width('100%')
      .height($r('app.float.mine_login_height'))
      .bindSheet(this.minePageState.isShowAccountInfo, this.LoginSheetViewBuilder(), {
        height: SheetSize.MEDIUM,
        preferType: SheetType.CENTER,
        hoverModeArea: HoverModeAreaType.BOTTOM_SCREEN,
        enableOutsideInteractive: false,
        blurStyle: BlurStyle.Regular,
        onWillDisappear: () => {
          MinePageVM.getInstance().sendEvent({ type: MineEventType.UPDATE_ACCOUNT_DATA, param: null })
        },
      })
      .onClick(this.throttle(() => {
        if (!this.minePageState.isLogin) {
          this.viewModel.sendEvent<null>({
            type: MineEventType.LOGIN,
            param: null,
          });
        } else {
          this.viewModel.sendEvent<null>({
            type: MineEventType.LOGOUT,
            param: null,
          });
        }
      }, MineConstant.BUTTON_CLICK_THROTTLE))
    }
    .height(undefined)
  }

  @Builder
  contentViewBuilder() {
    Scroll(this.scroller) {
      Column({ space: CommonConstants.SPACE_12 }) {
        ForEach(this.minePageState.listItemData, (groupData: ListGroup) => {
          Flex({
            direction: FlexDirection.Row,
            wrap: FlexWrap.Wrap
          }) {
            ForEach(groupData.group, (item: MineItem, index: number) => {
              if (item.type === BuilderEnum.LOGIN_ITEM) {
                this.itemHead()
              } else if (item.type === BuilderEnum.USER_EXPERIENCE_CARD) {
                UserExperienceCardItem({
                  textContent: item.textContent,
                  subTextContent: item.subTextContent,
                  onclick: () => {
                    this.bindSheetItem = item;
                    this.bindSheetShow = true;
                  },
                }) {
                  if (item.builder) {
                    item.builder.builder()
                  }
                }
              } else {
                Column() {
                  Divider()
                    .color($r('sys.color.comp_background_tertiary'))
                    .width(CommonConstants.FULL_PERCENT)
                    .padding({ left: CommonConstants.SPACE_40, right: $r('sys.float.padding_level6') })
                    .visibility(index < new BreakpointType<number>({
                      sm: 1,
                      md: 2,
                      lg: 2,
                    }).getValue(this.globalInfoModel.widthBreakpoint) ? Visibility.None : Visibility.Visible)
                  HmosListItem({
                    title: item.textContent,
                    prefixResource: item.symbolSrc,
                    badgeNum: item.showTotalNum ? this.minePageState.newContentNumber : 0,
                    handleClickAction: () => {
                      if (item.onclick) {
                        item.onclick();
                      } else {
                        this.bindSheetItem = item;
                        this.bindSheetShow = true;
                      }
                    }
                  })
                }
                .width(new BreakpointType<Length>({
                  sm: CommonConstants.FULL_PERCENT,
                  md: groupData.group.length > 1 ? CommonConstants.HALF_PERCENT : CommonConstants.FULL_PERCENT,
                  lg: groupData.group.length > 1 ? CommonConstants.HALF_PERCENT : CommonConstants.FULL_PERCENT,
                }).getValue(this.globalInfoModel.widthBreakpoint))
              }
            })
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))
          .padding($r('sys.float.padding_level2'))
        })
      }
      .width('100%')
      .margin({
        top: this.globalInfoModel.statusBarHeight + CommonConstants.NAVIGATION_HEIGHT,
        bottom: this.globalInfoModel.naviIndicatorHeight,
      })
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8')
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12')
        },
        lg: {
          left: (!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) && !HdsUtil.isSupportNewMaterialApi()) ?
            CommonConstants.TAB_BAR_WIDTH + CommonConstants.SPACE_32 : $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16')
        },
      }).getValue(this.globalInfoModel.widthBreakpoint))
      .bindSheet(this.bindSheetShow, this.bindSheetItem?.builder?.builder(), {
        showClose: true,
        preferType: (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM &&
          !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) ? SheetType.BOTTOM : SheetType.CENTER,
        height: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
          ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
            CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
        width: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? CommonConstants.SHEET_WIDTH_XL :
          undefined,
        onWillDisappear: () => {
          this.bindSheetShow = false;
        },
      })
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .align(Alignment.Top)
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
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
    HdsNavDestination() {
      this.contentViewBuilder();
    }
    .titleBar({
      padding: {
        start: LengthMetrics.vp((!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) &&
          (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
            this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) &&
          !HdsUtil.isSupportNewMaterialApi()) ? CommonConstants.TAB_BAR_WIDTH + CommonConstants.SPACE_32 :
          CommonConstants.SPACE_32)
      },
      avoidLayoutSafeArea: true,
      style: this.titleBarStyle,
      content: {
        title: { mainTitle: $r('app.string.mine_title') },
      }
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .defaultFocus(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .onReady((ctx: NavDestinationContext) => {
      const params: HomeListParams = ctx.pathInfo.param as HomeListParams;
      this.scroller = params?.scroller;
      this.homeTabController = params.homeTabController;
    })
    .onBackPressed(() => {
      return !!this.viewModel.sendEvent<null>({ type: BaseHomeEventType.ON_BACK_PRESS, param: null });
    })
  }
}

@Builder
export function MineViewBuilder() {
  MineView()
}