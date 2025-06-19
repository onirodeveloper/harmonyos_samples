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
import type { GlobalInfoModel, PageContext } from '@ohos/common';
import { BreakpointType, BreakpointTypeEnum, CommonConstants } from '@ohos/common';
import type { BannerData } from '@ohos/commonbusiness';
import {
  BannerCard,
  BaseHomeEventType,
  BaseHomeView,
  CalculateHeightParam,
  FullScreenNavigation,
  OffsetParam,
  TabBarType,
} from '@ohos/commonbusiness';
import { CategorySamples } from '../component/CategorySamples';
import type { SampleCategory } from '../model/SampleData';
import type { PracticeState } from '../viewmodel/PracticeState';
import { LoadSamplePageParam, PracticeEventType, PracticeViewModel } from '../viewmodel/PracticeViewModel';

@Component({ freezeWhenInactive: true })
export struct PracticesView {
  viewModel: PracticeViewModel = PracticeViewModel.getInstance();
  @StorageProp('GlobalInfoModel') @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get('GlobalInfoModel')!;
  @StorageProp('systemColorMode') @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get('systemColorMode')!;
  @State naviStatusHeight: number = CommonConstants.NAVIGATION_HEIGHT + this.globalInfoModel.statusBarHeight;
  @State currentIndex: number = 0;
  @State practiceState: PracticeState = this.viewModel.getState();
  @State showTopTab: boolean = true;
  private categoryTabController: TabsController = new TabsController();
  private listScroller: Scroller = new Scroller();
  private headerScroller: Scroller = new Scroller();
  private samplePageContext: PageContext = AppStorage.get('samplePageContext')!;
  private cornerNum: Length = this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? $r('sys.float.corner_radius_level4') : '50%';

  aboutToAppear(): void {
    this.viewModel.sendEvent<LoadSamplePageParam>({
      type: PracticeEventType.LOAD_SAMPLE_PAGE,
      param: {
        callback: () => {
          const categorySize: number = this.practiceState.sampleCategories.length;
          const preloadIndexList: number[] = [];
          for (let i = 0; i < categorySize; i++) {
            preloadIndexList.push(i);
          }
          this.categoryTabController.preloadItems(preloadIndexList);
        }
      },
    });
  }

  handleBreakPointChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: { yOffset: (this.listScroller?.currentOffset()?.yOffset || 0), tabIndex: TabBarType.SAMPLE },
    });
  }

  handleColorModeChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_COLOR_CHANGE,
      param: { yOffset: (this.listScroller?.currentOffset()?.yOffset || 0), tabIndex: TabBarType.SAMPLE },
    });
  }

  @Builder
  CategoryHeaderBuilder() {
    if (this.practiceState.sampleCategories.length > 1) {
      Scroll(this.headerScroller) {
        Row({
          space: new BreakpointType({
            sm: CommonConstants.SPACE_10,
            md: CommonConstants.SPACE_12,
            lg: CommonConstants.SPACE_12,
          }).getValue(this.globalInfoModel.currentBreakpoint),
        }) {
          ForEach(this.practiceState.sampleCategories, (item: SampleCategory, index: number) => {
            Row() {
              if (item.tabIcon) {
                Image($rawfile(this.currentIndex === index ? item.tabIcon : item.tabIconSelected))
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
            .backgroundColor(this.currentIndex === index ? $r('sys.color.brand') :
            $r('sys.color.ohos_id_color_button_normal'))
            .padding({
              left: $r('sys.float.padding_level8'),
              right: $r('sys.float.padding_level8'),
              top: $r('sys.float.padding_level4'),
              bottom: $r('sys.float.padding_level4'),
            })
            .borderRadius(this.cornerNum)
            .onClick(() => {
              this.currentIndex = index;
              if (!this.practiceState.sampleCategories[index].sampleCards) {
                const topOffsetY =
                  (this.practiceState.bannerState.bannerHeight - this.globalInfoModel.naviIndicatorHeight -
                  CommonConstants.NAVIGATION_HEIGHT);
                if (this.listScroller?.currentOffset()?.yOffset > topOffsetY) {
                  this.listScroller.scrollTo({ yOffset: topOffsetY, xOffset: 0 });
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
          }).getValue(this.globalInfoModel.currentBreakpoint),
          right: $r('sys.float.padding_level6'),
          bottom: $r('sys.float.padding_level5'),
          top: $r('sys.float.padding_level8'),
        })
      }
      .align(Alignment.Start)
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
  }

  @Builder
  ContentViewBuilder() {
    List({
      scroller: this.listScroller,
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

      ListItemGroup({ header: this.CategoryHeaderBuilder() }) {
        ListItem() {
          Tabs({ index: this.currentIndex, controller: this.categoryTabController }) {
            ForEach(this.practiceState.sampleCategories, (sampleCategory: SampleCategory) => {
              TabContent() {
                CategorySamples({ sampleCategory })
              }
            }, (item: SampleCategory) => `${item.categoryType}_${item.sampleCards?.length}`)
          }
          .scrollable(false)
          .barHeight(0)
        }
      }
      .padding({
        left: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ? CommonConstants.TAB_BAR_WIDTH : 0,
      })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .clip(false)
    .edgeEffect(this.practiceState.hasEdgeEffect ? EdgeEffect.Spring : EdgeEffect.None)
    .sticky(StickyStyle.Header)
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      const param: CalculateHeightParam = { offset, state, yOffset: this.listScroller.currentOffset().yOffset };
      const bannerChangeHeight: boolean | void = this.viewModel.sendEvent<CalculateHeightParam>({
        type: BaseHomeEventType.CALCULATE_BANNER_HEIGHT,
        param,
      });
      if (bannerChangeHeight) {
        return { offsetRemain: 0 };
      }
      return { offsetRemain: offset };
    })
    .onDidScroll(() => {
      this.viewModel.sendEvent<OffsetParam>({
        type: BaseHomeEventType.HANDLE_SCROLL_OFFSET,
        param: { yOffset: this.listScroller.currentOffset().yOffset, tabIndex: TabBarType.SAMPLE },
      });
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  TopTitleViewBuilder() {
    FullScreenNavigation({
      topNavigationData: this.practiceState.topNavigationData,
      tabView: () => {
        this.CategoryHeaderBuilder()
      },
    })
  }

  build() {
    Navigation(this.samplePageContext.navPathStack) {
      BaseHomeView({
        loadingModel: this.practiceState.loadingModel,
        contentView: () => {
          this.ContentViewBuilder()
        },
        topTitleView: () => {
          this.TopTitleViewBuilder()
        },
        reloadData: () => {
          this.viewModel.sendEvent({ type: PracticeEventType.LOAD_SAMPLE_PAGE, param: null });
        },
      })
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}