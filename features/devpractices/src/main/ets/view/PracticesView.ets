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
import { CommonModifier } from '@kit.ArkUI';
import {
  HdsNavDestination, HdsTabsController, HideMode,
} from '@kit.UIDesignKit';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  StorageKey,
  HdsUtil,
  TrackServiceData,
  TRACK_KEY,
} from '@ohos/common';
import type { BannerData, HomeListParams, InitializeParam, TabBarAnimationParam } from '@ohos/commonbusiness';
import {
  BannerCard,
  BaseHomeEventType,
  BaseHomeView,
  CalculateHeightParam,
  OffsetParam,
  TabBarType,
} from '@ohos/commonbusiness';
import { CategorySamples } from '../component/CategorySamples';
import type { SampleCategory } from '../model/SampleData';
import type { PracticeState } from '../viewmodel/PracticeState';
import { LoadSamplePageParam, PracticeEventType, PracticeViewModel } from '../viewmodel/PracticeViewModel';

@Component({ freezeWhenInactive: true })
struct PracticesView {
  private viewModel: PracticeViewModel = PracticeViewModel.getInstance();
  private headerScroller: Scroller = new Scroller();
  private tabScroller: Scroller = new Scroller();
  homeTabController: HdsTabsController = new HdsTabsController();
  isReachEnd: boolean = false;
  scroller: Scroller = new Scroller();
  private categoryTabController: TabsController = new TabsController();
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @State naviStatusHeight: number = CommonConstants.NAVIGATION_HEIGHT + this.globalInfoModel.statusBarHeight;
  @State currentIndex: number = 0;
  @State practiceState: PracticeState = this.viewModel.getState();
  @State showTopTab: boolean = true;
  @State materialModifier: CommonModifier = new CommonModifier();
  @State selMaterialModifier: CommonModifier = new CommonModifier();

  aboutToAppear(): void {
    this.viewModel.sendEvent<LoadSamplePageParam>({
      type: PracticeEventType.LOAD_SAMPLE_PAGE,
      param: {
        callback: () => {
          this.preloadCategory();
        }
      },
    });
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: { yOffset: 0, tabIndex: TabBarType.SAMPLE },
    });
    this.materialModifier.backgroundColor($r('sys.color.ohos_id_color_button_normal'));
    this.selMaterialModifier.backgroundColor($r('sys.color.ohos_id_color_emphasize'));
  }

  preloadCategory() {
    const categorySize: number = this.practiceState.sampleCategories.length;
    const preloadIndexList: number[] = [];
    for (let i = 0; i < categorySize; i++) {
      preloadIndexList.push(i);
    }
    this.categoryTabController.preloadItems(preloadIndexList);
  }

  handleBreakPointChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: {
        yOffset: (this.scroller?.currentOffset()?.yOffset || 0),
        tabIndex: TabBarType.SAMPLE,
      },
    });
  }

  handleColorModeChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_COLOR_CHANGE,
      param: {
        yOffset: (this.scroller?.currentOffset()?.yOffset || 0),
        tabIndex: TabBarType.SAMPLE,
      },
    });
  }

  @Builder
  CategoryHeaderBuilder(isHeader: boolean, hasStartMargin?: boolean) {
    if (this.practiceState.sampleCategories.length > 1) {
      Scroll(isHeader ? this.headerScroller : this.tabScroller) {
        Row({
          space: new BreakpointType({
            sm: CommonConstants.SPACE_10,
            md: CommonConstants.SPACE_12,
            lg: CommonConstants.SPACE_12,
          }).getValue(this.globalInfoModel.widthBreakpoint),
        }) {
          ForEach(this.practiceState.sampleCategories, (item: SampleCategory, index: number) => {
            Row() {
              if (item.defaultIcon) {
                Image($rawfile(this.currentIndex === index ? item.defaultIcon : item.selectedIcon))
                  .height($r('app.float.tab_icon_height'))
                  .objectFit(ImageFit.Contain)
                  .margin({ right: $r('sys.float.padding_level2') })
              }
              Text(item.categoryName)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor(this.currentIndex === index ? $r('sys.color.font_on_primary') :
                  $r('sys.color.font_tertiary'))
            }
            .attributeModifier(this.currentIndex === index ? this.selMaterialModifier : this.materialModifier)
            .padding({
              left: $r('sys.float.padding_level8'),
              right: $r('sys.float.padding_level8'),
              top: $r('sys.float.padding_level4'),
              bottom: $r('sys.float.padding_level4'),
            })
            .customProperty(TRACK_KEY, {
              secondaryTab: item.categoryName,
            } as TrackServiceData)
            .margin({ left: (hasStartMargin && index === 0) ? CommonConstants.TAB_BAR_WIDTH : 0 })
            .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
              $r('sys.float.corner_radius_level4') : '50%')
            .onClick(() => {
              this.currentIndex = index;
              if (!this.practiceState.sampleCategories[index].sampleCards) {
                const topOffsetY =
                  (this.practiceState.bannerState.bannerHeight - this.globalInfoModel.naviIndicatorHeight -
                    CommonConstants.NAVIGATION_HEIGHT);
                if (this.scroller?.currentOffset()?.yOffset > topOffsetY) {
                  this.scroller.scrollTo({ yOffset: topOffsetY, xOffset: 0 });
                }
              }
            })
          }, (item: SampleCategory) => item.id.toString())
        }
        .padding({
          left: new BreakpointType({
            sm: $r('sys.float.padding_level6'),
            md: $r('sys.float.padding_level12'),
            lg: $r('sys.float.padding_level16'),
          }).getValue(this.globalInfoModel.widthBreakpoint),
          right: new BreakpointType({
            sm: $r('sys.float.padding_level6'),
            md: $r('sys.float.padding_level12'),
            lg: $r('sys.float.padding_level16'),
          }).getValue(this.globalInfoModel.widthBreakpoint),
          bottom: $r('sys.float.padding_level5'),
          top: $r('sys.float.padding_level8'),
        })
      }
      .onAppear(() => {
        if (isHeader) {
          const offset: OffsetResult = this.tabScroller.currentOffset();
          this.headerScroller.scrollTo({
            xOffset: offset?.xOffset ?? 0,
            yOffset: offset?.yOffset ?? 0,
            animation: false,
          });
        }
      })
      .initialOffset(isHeader ? this.tabScroller.currentOffset() : {})
      .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
        if (scrollState !== ScrollState.Idle) {
          if (isHeader) {
            this.tabScroller.scrollTo(this.headerScroller.currentOffset());
          } else {
            this.headerScroller.scrollTo(this.tabScroller.currentOffset());
          }
        }
      })
      .visibility(this.practiceState.showTab && !isHeader ? Visibility.Hidden : Visibility.Visible)
      .align(Alignment.Start)
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
  }

  @Builder
  ContentViewBuilder() {
    List({
      scroller: this.scroller,
      space: this.practiceState.sampleCategories.length === 1 ? CommonConstants.SPACE_12 : 0,
    }) {
      ListItem() {
        BannerCard({
          tabViewType: TabBarType.SAMPLE,
          bannerState: this.practiceState.bannerState,
          handleItemClick: (banner: BannerData) => {
            this.viewModel.sendEvent<BannerData>({ type: BaseHomeEventType.JUMP_BANNER_DETAIL, param: banner });
          },
        })
      }
      .height(this.practiceState.bannerHeight)

      ListItemGroup({ header: this.CategoryHeaderBuilder(false) }) {
        ListItem() {
          Tabs({ index: this.currentIndex, controller: this.categoryTabController }) {
            ForEach(this.practiceState.sampleCategories, (sampleCategory: SampleCategory) => {
              TabContent() {
                CategorySamples({ sampleCategory })
              }
            }, (item: SampleCategory) => `${item.id}_${item.sampleCards?.length}`)
          }
          .scrollable(false)
          .onAttach(() => {
            this.preloadCategory();
          })
          .barHeight(0)
        }
      }
      .padding({
        left: (!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) &&
          (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
            this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) &&
          !HdsUtil.isSupportNewMaterialApi()) ? CommonConstants.TAB_BAR_WIDTH : 0,
      })
    }
    .sticky(StickyStyle.None)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .clip(false)
    .edgeEffect(this.practiceState.hasEdgeEffect ? EdgeEffect.Spring : EdgeEffect.None)
    .sticky(StickyStyle.Header)
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      if (state === ScrollState.Scroll) {
        this.viewModel.sendEvent<TabBarAnimationParam>({
          type: BaseHomeEventType.HANDLE_TAB_BAR_ANIMATION,
          param: {
            yOffset: offset,
            tabIndex: TabBarType.SAMPLE,
          } as TabBarAnimationParam,
        });
      }
      const param: CalculateHeightParam = { offset, state, yOffset: this.scroller.currentOffset()?.yOffset ?? 0 };
      const bannerChangeHeight: boolean = !!this.viewModel.sendEvent<CalculateHeightParam>({
        type: BaseHomeEventType.CALCULATE_BANNER_HEIGHT,
        param,
      });
      if (bannerChangeHeight) {
        return { offsetRemain: 0 };
      }
      return { offsetRemain: offset };
    })
    .onReachEnd(() => {
      if (this.isReachEnd) {
        this.viewModel.sendEvent<TabBarAnimationParam>({
          type: BaseHomeEventType.HANDLE_TAB_BAR_ANIMATION,
          param: {
            yOffset: -1,
            tabIndex: TabBarType.SAMPLE,
          } as TabBarAnimationParam,
        });
      }
      this.isReachEnd = true;
    })
    .onReachStart(() => {
      this.isReachEnd = false;
    })
    .onDidScroll(() => {
      this.viewModel.sendEvent<OffsetParam>({
        type: BaseHomeEventType.HANDLE_SCROLL_OFFSET,
        param: { yOffset: this.scroller.currentOffset().yOffset, tabIndex: TabBarType.SAMPLE },
      });
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  PracticeContentView() {
    BaseHomeView({
      loadingModel: this.practiceState.loadingModel,
      contentView: () => {
        this.ContentViewBuilder()
      },
      reloadData: () => {
        this.viewModel.sendEvent({ type: PracticeEventType.LOAD_SAMPLE_PAGE, param: null });
      },
    })
  }

  build() {
    HdsNavDestination() {
      this.PracticeContentView();
    }
    .hideBackButton(true)
    .bindToScrollable([this.scroller])
    .dynamicHideTitleBar({
      hideTitleArea: !AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT),
      mode: HideMode.SCROLL_UP_TO,
      hideRatio: 1,
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .titleBar({
      padding: this.practiceState.topNavigationData.hdsTitleBarPadding,
      avoidLayoutSafeArea: true,
      style: this.practiceState.topNavigationData.hdsTitleBarStyle,
      content: {
        title: { mainTitle: this.practiceState.topNavigationData.title },
        bottomBuilder: this.practiceState.showTab ? {
          builder: () => {
            this.CategoryHeaderBuilder(true,!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) &&
              (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
                this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) &&
              !HdsUtil.isSupportNewMaterialApi());
          },
        } : undefined,
      }
    })
    .onReady((ctx: NavDestinationContext) => {
      const params: HomeListParams = ctx.pathInfo.param as HomeListParams;
      this.scroller = params?.scroller;
      this.homeTabController = params.homeTabController;
      this.viewModel.sendEvent<InitializeParam>({
        type: BaseHomeEventType.INITIALIZE,
        param: {
          homeTabController: this.homeTabController,
        },
      });
    })
    .onBackPressed(() => {
      return !!this.viewModel.sendEvent<null>({ type: BaseHomeEventType.ON_BACK_PRESS, param: null });
    })
  }
}

@Builder
export function PracticesViewBuilder() {
  PracticesView()
}