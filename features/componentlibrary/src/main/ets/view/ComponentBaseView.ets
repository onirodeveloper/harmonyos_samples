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
import { BreakpointType, CommonConstants, DebounceUtil, GlobalInfoModel, StorageKey } from '@ohos/common';
import type { BannerData, TabBarAnimationParam } from '@ohos/commonbusiness';
import {
  BannerCard,
  BaseHomeEventType,
  BaseHomeView,
  CalculateHeightParam,
  CardStyleTypeEnum,
  LoadingMoreItemBuilder,
  OffsetParam,
  TabBarType,
} from '@ohos/commonbusiness';
import { CodeLabCard } from '../component/CodeLabCard';
import { ListCard } from '../component/ListCard';
import { PictureListCard } from '../component/PictureListCard';
import type { ComponentCardData, ComponentContent } from '../model/ComponentData';
import type { ComponentListState } from '../viewmodel/ComponentListState';
import { ComponentListEventType, ComponentListViewModel } from '../viewmodel/ComponentListViewModel';

@Component({ freezeWhenInactive: true })
export struct ComponentBaseView {
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  viewModel: ComponentListViewModel = ComponentListViewModel.getInstance();
  @State componentListState: ComponentListState = this.viewModel.getState();

  aboutToAppear(): void {
    this.viewModel.sendEvent({ type: ComponentListEventType.LOAD_COMPONENT_PAGE, param: null });
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: { yOffset: 0, tabIndex: TabBarType.HOME },
    });
  }

  handleBreakPointChange() {
    this.viewModel.sendEvent({ type: ComponentListEventType.UPDATE_FLOW_SECTION, param: null });
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_BREAKPOINT_CHANGE,
      param: {
        yOffset: (this.componentListState.scroller?.currentOffset()?.yOffset || 0),
        tabIndex: TabBarType.HOME,
      },
    });
  }

  handleColorModeChange() {
    this.viewModel.sendEvent<OffsetParam>({
      type: BaseHomeEventType.HANDLE_COLOR_CHANGE,
      param: {
        yOffset: (this.componentListState.scroller?.currentOffset()?.yOffset || 0),
        tabIndex: TabBarType.HOME,
      },
    });
  }

  jumpComponentDetailView(componentContent: ComponentContent): Function {
    return DebounceUtil.debounce(() => {
      this.viewModel.sendEvent<ComponentContent>({
        type: ComponentListEventType.JUMP_DETAIL_DETAIL,
        param: componentContent,
      });
    }, 1000);
  }

  jumpCodelabDetailView(componentCard: ComponentCardData): Function {
    return this.jumpComponentDetailView(componentCard.componentContents?.[0]);
  }

  jumpBannerDetail(banner: BannerData) {
    this.viewModel.sendEvent<BannerData>({ type: BaseHomeEventType.JUMP_BANNER_DETAIL, param: banner });
  }

  @Builder
  ContentViewBuilder() {
    WaterFlow({
      scroller: this.componentListState.scroller,
      sections: this.componentListState.sections,
    }) {
      FlowItem() {
        BannerCard({
          tabViewType: TabBarType.HOME,
          bannerState: this.componentListState.bannerState,
          handleItemClick: (banner: BannerData) => {
            this.jumpBannerDetail(banner);
          },
        })
      }
      .height(this.componentListState.bannerHeight)
      .width('100%')

      LazyForEach(this.componentListState.cardSource, (item: ComponentCardData) => {
        FlowItem() {
          if (item.styleType === CardStyleTypeEnum.PICTURE_ABOVE_LIST) {
            PictureListCard({
              componentCardData: item,
              widthBreakpoint: this.globalInfoModel.widthBreakpoint,
              handleItemClick: (componentContent: ComponentContent) => {
                this.jumpComponentDetailView(componentContent)();
              },
            })
              .reuseId(CardStyleTypeEnum.PICTURE_ABOVE_LIST.toString())
          } else if (item.styleType === CardStyleTypeEnum.LIST) {
            ListCard({
              componentCardData: item,
              handleItemClick: (componentContent: ComponentContent) => {
                this.jumpComponentDetailView(componentContent)();
              },
            })
              .reuseId(CardStyleTypeEnum.LIST.toString())
          } else {
            CodeLabCard({
              componentCardData: item,
            })
              .reuseId(CardStyleTypeEnum.PICTURE.toString())
              .onClick(() => {
                this.jumpCodelabDetailView(item)();
              })
          }
        }
        .width('100%')
      }, (item: ComponentCardData) => item.id.toString())
      FlowItem() {
        LoadingMoreItemBuilder(this.componentListState.loadingModel)
      }
      .width('100%')
      .padding({
        bottom: (this.globalInfoModel.naviIndicatorHeight +
          (AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? 0 : CommonConstants.TAB_BAR_HEIGHT)),
      })
    }
    .columnsGap(new BreakpointType({
      sm: $r('sys.float.padding_level6'),
      md: $r('sys.float.padding_level6'),
      lg: $r('sys.float.padding_level8'),
      xl: $r('sys.float.padding_level8'),
    }).getValue(this.globalInfoModel.widthBreakpoint))
    .rowsGap(new BreakpointType({
      sm: $r('sys.float.padding_level8'),
      md: $r('sys.float.padding_level6'),
      lg: $r('sys.float.padding_level8'),
      xl: $r('sys.float.padding_level12')
    }).getValue(this.globalInfoModel.widthBreakpoint))
    .edgeEffect(this.componentListState.hasEdgeEffect ? EdgeEffect.Spring : EdgeEffect.None)
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      this.viewModel.sendEvent<TabBarAnimationParam>({
        type: BaseHomeEventType.HANDLE_TAB_BAR_ANIMATION,
        param: {
          yOffset: offset,
          tabIndex: TabBarType.HOME,
        } as TabBarAnimationParam,
      });
      const param: CalculateHeightParam =
        { offset, state, yOffset: this.componentListState.scroller.currentOffset()?.yOffset ?? 0 };
      const bannerHeightChange: boolean | void = this.viewModel.sendEvent<CalculateHeightParam>({
        type: BaseHomeEventType.CALCULATE_BANNER_HEIGHT,
        param,
      }) as boolean;
      if (bannerHeightChange) {
        return { offsetRemain: 0 };
      }
      return { offsetRemain: offset };
    })
    .onReachEnd(() => {
      this.viewModel.sendEvent<TabBarAnimationParam>({
        type: BaseHomeEventType.HANDLE_TAB_BAR_ANIMATION,
        param: {
          yOffset: -1,
          tabIndex: TabBarType.HOME,
        } as TabBarAnimationParam,
      });
    })
    .width('100%')
    .height('100%')
    .cachedCount(20)
    .onDidScroll(() => {
      this.viewModel.sendEvent<OffsetParam>({
        type: BaseHomeEventType.HANDLE_SCROLL_OFFSET,
        param: { yOffset: this.componentListState.scroller.currentOffset().yOffset, tabIndex: TabBarType.HOME },
      });
    })
  }

  build() {
    BaseHomeView({
      loadingModel: this.componentListState.loadingModel,
      contentView: () => {
        this.ContentViewBuilder()
      },
      reloadData: () => {
        this.viewModel.sendEvent({ type: ComponentListEventType.LOAD_COMPONENT_PAGE, param: null });
      },
    })
  }
}