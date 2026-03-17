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
import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { BreakpointType, CommonConstants, GlobalInfoModel, PageContext, StorageKey, VersionUtil } from '@ohos/common';
import type { BannerData } from '@ohos/commonbusiness';
import {
  BannerCard,
  BaseHomeEventType,
  BaseHomeView,
  CalculateHeightParam,
  FullScreenNavigation,
  LoadingMoreItemBuilder,
  OffsetParam,
  TabBarType,
} from '@ohos/commonbusiness';
import { DeveloperCard } from '../component/DeveloperCard';
import { ExperienceCard } from '../component/ExperienceCard';
import { FeedCard } from '../component/FeedCard';
import type { DiscoverCardData, DiscoverContent } from '../model/DiscoverData';
import { ArticleStyleTypeEnum } from '../model/DiscoverData';
import type { ExplorationState } from '../viewmodel/ExplorationState';
import { ExplorationEventType, ExplorationViewModel } from '../viewmodel/ExplorationViewModel';

@Component({ freezeWhenInactive: true })
export struct ExplorationView {
  viewModel: ExplorationViewModel = ExplorationViewModel.getInstance();
  scroller: Scroller = new Scroller();
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @StorageLink(StorageKey.EXPLORATION_PAGE_CONTEXT) explorationPageContext: PageContext =
    AppStorage.get<PageContext>(StorageKey.EXPLORATION_PAGE_CONTEXT) ?? new PageContext();
  @State explorationState: ExplorationState = this.viewModel.getState();

  aboutToAppear(): void {
    this.viewModel.sendEvent({ type: ExplorationEventType.LOAD_DISCOVERY_PAGE, param: null });
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: { yOffset: 0, tabIndex: TabBarType.PRACTICE },
    });
  }

  handleBreakPointChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: { yOffset: (this.scroller?.currentOffset()?.yOffset || 0), tabIndex: TabBarType.PRACTICE },
    });
  }

  handleColorModeChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_COLOR_CHANGE,
      param: { yOffset: (this.scroller?.currentOffset()?.yOffset || 0), tabIndex: TabBarType.PRACTICE },
    });
  }

  jumpArticleDetail(componentContent: DiscoverContent) {
    this.viewModel.sendEvent<DiscoverContent>({
      type: ExplorationEventType.JUMP_DETAIL_VIEW,
      param: componentContent,
    });
  }

  jumpBannerDetail(banner: BannerData) {
    this.viewModel.sendEvent<BannerData>({ type: BaseHomeEventType.JUMP_BANNER_DETAIL, param: banner });
  }

  @Builder
  CategoryHeaderBuilder(groupItem: string) {
    Row() {
      Text(groupItem)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .padding({
      top: $r('sys.float.padding_level4'),
      bottom: $r('sys.float.padding_level4'),
      left: new BreakpointType<Length>({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: CommonConstants.SPACE_32 + CommonConstants.TAB_BAR_WIDTH,
        xl: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.widthBreakpoint),
    })
  }

  @Builder
  ContentViewBuilder() {
    List({ scroller: this.scroller, space: CommonConstants.SPACE_16 }) {
      ListItem() {
        BannerCard({
          tabViewType: TabBarType.PRACTICE,
          bannerState: this.explorationState.bannerState,
          handleItemClick: (banner: BannerData) => {
            this.viewModel.sendEvent<BannerData>({ type: BaseHomeEventType.JUMP_BANNER_DETAIL, param: banner });
          },
        })
      }
      .height(this.explorationState.bannerHeight)

      Repeat(this.explorationState.discoveryData)
        .each((repeatItem: RepeatItem<DiscoverCardData>) => {
          ListItem() {
            Column() {
              this.CategoryHeaderBuilder(repeatItem.item.name)
              FeedCard({
                discoverContents: repeatItem.item.contents,
                handleItemClick: (content: DiscoverContent) => {
                  this.jumpArticleDetail(content);
                },
              })
            }
          }
        })
        .key((item: DiscoverCardData) => item.id.toString())
        .templateId((item: DiscoverCardData) => item.styleType.toString())
        .template(ArticleStyleTypeEnum.EXPERIENCES.toString(), (repeatItem: RepeatItem<DiscoverCardData>) => {
          ListItem() {
            Column() {
              this.CategoryHeaderBuilder(repeatItem.item.name)
              ExperienceCard({
                discoverContents: repeatItem.item.contents,
                handleItemClick: (content: DiscoverContent) => {
                  this.jumpArticleDetail(content);
                },
              })
                .margin({
                  left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ?
                    $r('sys.float.padding_level8') : 0,
                  right: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ?
                    $r('sys.float.padding_level8') : 0,
                })
            }
          }
        })
        .template(ArticleStyleTypeEnum.DEVELOPER.toString(), (repeatItem: RepeatItem<DiscoverCardData>) => {
          ListItem() {
            Column() {
              this.CategoryHeaderBuilder(repeatItem.item.name)
              DeveloperCard({
                discoverContents: repeatItem.item.contents,
                handleItemClick: (content: DiscoverContent) => {
                  this.jumpArticleDetail(content);
                },
              })
            }
          }
        })
      ListItem() {
        LoadingMoreItemBuilder(this.explorationState.loadingModel)
      }
      .padding({
        left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ?
          CommonConstants.TAB_BAR_WIDTH + CommonConstants.SPACE_16 : CommonConstants.SPACE_16,
        right: CommonConstants.SPACE_16,
        bottom: (this.globalInfoModel.naviIndicatorHeight +
          (new BreakpointType({
            sm: CommonConstants.TAB_BAR_HEIGHT,
            md: CommonConstants.TAB_BAR_HEIGHT,
            lg: 0,
          }).getValue(this.globalInfoModel.widthBreakpoint))),
      })
    }
    .width('100%')
    .height('100%')
    .clip(false)
    .scrollBar(BarState.Off)
    .edgeEffect(this.explorationState.hasEdgeEffect ? EdgeEffect.Spring : EdgeEffect.None)
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      const param: CalculateHeightParam = { offset, state, yOffset: this.scroller.currentOffset()?.yOffset ?? 0 };
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
      if (!VersionUtil.canUseHds()) {
        this.viewModel.sendEvent<OffsetParam>({
          type: BaseHomeEventType.HANDLE_SCROLL_OFFSET,
          param: { yOffset: this.scroller.currentOffset().yOffset, tabIndex: TabBarType.PRACTICE },
        });
      }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  TopTitleViewBuilder() {
    FullScreenNavigation({
      topNavigationData: this.explorationState.topNavigationData,
    })
  }

  @Builder
  ExplorationContentView() {
    BaseHomeView({
      loadingModel: this.explorationState.loadingModel,
      contentView: () => {
        this.ContentViewBuilder()
      },
      topTitleView: () => {
        this.TopTitleViewBuilder()
      },
      reloadData: () => {
        this.viewModel.sendEvent({ type: ExplorationEventType.LOAD_DISCOVERY_PAGE, param: null });
      },
    })
  }

  build() {
    if (VersionUtil.canUseHds()) {
      HdsNavigation(this.explorationPageContext.navPathStack) {
        this.ExplorationContentView();
      }
      .mode(NavigationMode.Stack)
      .hideBackButton(true)
      .titleMode(HdsNavigationTitleMode.MINI)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
      .titleBar({
        padding: this.explorationState.topNavigationData.hdsTitleBarPadding,
        avoidLayoutSafeArea: true,
        style: this.explorationState.topNavigationData.hdsTitleBarStyle,
        content: {
          title: { mainTitle: this.explorationState.topNavigationData.title },
        }
      })
      .width('100%')
      .height('100%')
    } else {
      Navigation(this.explorationPageContext.navPathStack) {
        this.ExplorationContentView();
      }
      .mode(NavigationMode.Stack)
      .hideTitleBar(true)
    }
  }
}