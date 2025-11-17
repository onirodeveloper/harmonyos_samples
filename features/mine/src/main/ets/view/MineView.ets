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

import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import type { GlobalInfoModel, PageContext } from '@ohos/common';
import {
  BreakpointType,
  CommonConstants,
  HmosListItem,
  StorageKey,
  TopNavigationView,
  VersionUtil,
} from '@ohos/common';
import { InitEvent, LoadContentNumberEvent, MinePageVM } from '../viewmodel/MinePageVM';
import { BuilderEnum, ListGroup, MineItem, MinePageState } from '../viewmodel/MinePageState';
import { UserExperienceCardItem } from '../component/UserExperienceCardItem';

@Component
export struct MineView {
  viewModel: MinePageVM = MinePageVM.getInstance();
  @State minePageState: MinePageState = this.viewModel.getState();
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;
  @State bindSheetShow: boolean = false;
  @State bindSheetItem?: MineItem = undefined;
  scroller: Scroller = new Scroller();
  private minePageContext: PageContext = AppStorage.get(StorageKey.MINE_PAGE_CONTEXT)!;

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

  aboutToAppear(): void {
    this.viewModel.sendEvent(new InitEvent());
    this.viewModel.sendEvent(new LoadContentNumberEvent());
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
              if (item.type === BuilderEnum.USER_EXPERIENCE_CARD) {
                UserExperienceCardItem({
                  textContent: item.textContent,
                  subTextContent: item.subTextContent,
                  onclick: item.onclick,
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
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16')
        },
      }).getValue(this.globalInfoModel.widthBreakpoint))
      .bindSheet(this.bindSheetShow, this.bindSheetItem?.builder?.builder(), {
        showClose: true,
        preferType: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? SheetType.BOTTOM :
          SheetType.CENTER,
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

  build() {
    if (VersionUtil.canUseHds()) {
      HdsNavigation(this.minePageContext.navPathStack) {
        this.contentViewBuilder();
      }
      .titleBar({
        avoidLayoutSafeArea: true,
        style: {
          scrollEffectOpts: {
            enableScrollEffect: true,
          }
        },
        content: {
          title: { mainTitle: $r('app.string.mine_title') },
        }
      })
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .defaultFocus(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .titleMode(HdsNavigationTitleMode.MINI)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
      .padding({
        left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? CommonConstants.TAB_BAR_WIDTH : 0,
      })
    } else {
      Navigation(this.minePageContext.navPathStack) {
        Stack({ alignContent: Alignment.Top }) {
          this.contentViewBuilder()
          TopNavigationView({
            topNavigationData: {
              fontSize: new BreakpointType({
                sm: $r('sys.float.Title_M'),
                md: $r('sys.float.Title_L'),
                lg: $r('sys.float.Title_L'),
                xl: $r('sys.float.Title_S'),
              }).getValue(this.globalInfoModel.widthBreakpoint),
              bgColor: $r('sys.color.background_secondary'),
              title: $r('app.string.mine_title'),
              isFullScreen: true,
            }
          })
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .defaultFocus(true)
      .mode(NavigationMode.Stack)
      .hideTitleBar(true)
      .padding({
        left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? CommonConstants.TAB_BAR_WIDTH : 0,
      })
    }
  }
}