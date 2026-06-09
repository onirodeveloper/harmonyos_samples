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

import { SegmentButton, SegmentButtonItemTuple, SegmentButtonOptions, } from '@kit.ArkUI';
import {
  hdsMaterial,
  HdsNavDestination,
  HdsNavDestinationAttribute,
  ScrollEffectType,
  TitleBarStyleOptions
} from '@kit.UIDesignKit';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  HdsUtil,
  LoadingStatus,
  StorageKey,
} from '@ohos/common';
import { BaseDetailComponent } from '@ohos/commonbusiness';
import {
  AssignViewData,
  ChangeBackPressed,
  InitContentNewEvent,
  NewContentVM,
  PopEvent,
} from '../viewmodel/NewContentVM';
import { NewContentPageState } from '../viewmodel/NewContentPageState';
import { NewContentItem } from '../component/NewContentItem';

@Component
export struct NewContentView {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State loadingStatus: LoadingStatus = LoadingStatus.IDLE;
  @State currentIndex: number = 0;
  @State titleBarStyle: TitleBarStyleOptions = {
    scrollEffectOpts: {
      scrollEffectType: ScrollEffectType.COMMON_BLUR,
      enableScrollEffect: false,
    },
  };
  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [
      { text: $r('app.string.component') },
      { text: $r('app.string.sample') },
      { text: $r('app.string.article') },
    ] as SegmentButtonItemTuple,
    backgroundColor: $r('sys.color.comp_background_tertiary'),
    fontSize: $r('sys.float.Body_M'),
    multiply: false,
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable'),
    selectedFontColor: $r('sys.color.font_primary'),
    fontColor: $r('sys.color.font_secondary'),
    textPadding: {
      top: $r('sys.float.padding_level4'),
      bottom: $r('sys.float.padding_level4'),
    },
  })
  @State @Watch('tabSelectedIndexChange') tabSelectedIndexes: number[] = [0];
  private viewModel?: NewContentVM = NewContentVM.getInstance();
  @State newContentPageState?: NewContentPageState = this.viewModel?.getState();

  aboutToAppear(): void {
    if (HdsUtil.isSupportNewMaterialApi()) {
      this.titleBarStyle = {
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
        scrollEffectOpts: {
          enableScrollEffect: false,
          scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
            ScrollEffectType.COMMON_BLUR,
        },
      }
    }
  }

  handleOnReady(ctx: NavDestinationContext) {
    this.viewModel?.sendEvent(new AssignViewData(ctx.pathStack));
    this.viewModel?.sendEvent(new InitContentNewEvent(this.tabSelectedIndexes[0]));
    this.viewModel?.sendEvent(new ChangeBackPressed(false));
  }

  @Builder
  TabComponent() {
    Tabs({ index: this.tabSelectedIndexes[0] }) {
      TabContent() {
        NewContentItem({
          contentData: this.newContentPageState?.newComponentData,
          emptyDescription: $r('app.string.no_component_content'),
        })
      }

      TabContent() {
        NewContentItem({
          contentData: this.newContentPageState?.newSampleData,
          emptyDescription: $r('app.string.no_sample_content'),
        })
      }

      TabContent() {
        NewContentItem({
          contentData: this.newContentPageState?.newArticleData,
          emptyDescription: $r('app.string.no_article_content'),
        })
      }
    }
    .layoutWeight(1)
    .barWidth(0)
    .barHeight(0)
    .scrollable(false)
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  ContentTabs() {
    Column() {
      SegmentButton({ options: this.singleSelectCapsuleOptions, selectedIndexes: $tabSelectedIndexes })
        .width(new BreakpointType<Length>({
          sm: CommonConstants.FULL_PERCENT,
          md: CommonConstants.HALF_PERCENT,
          lg: CommonConstants.HALF_PERCENT,
        }).getValue(this.globalInfoModel.widthBreakpoint))
        .margin({
          top: $r('sys.float.padding_level6'),
        })
      this.TabComponent()
    }
    .padding({
      top: CommonConstants.NAVIGATION_HEIGHT + this.globalInfoModel.statusBarHeight,
      left: new BreakpointType({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.widthBreakpoint),
      right: new BreakpointType({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.widthBreakpoint),
    })
  }

  @Builder
  ContentBuilder() {
    BaseDetailComponent({
      detailContentView: () => {
        this.ContentTabs()
      },
      reloadData: () => {
        this.viewModel?.sendEvent(new InitContentNewEvent(this.tabSelectedIndexes[this.currentIndex]));
      },
      loadingStatus: this.newContentPageState?.loadingStatus,
    })
  }

  build() {
    HdsNavDestination() {
      this.ContentBuilder()
    }
    .hideBackButton(false)
    .titleBar({
      style: this.titleBarStyle,
      content: {
        title: { mainTitle: $r('app.string.content_new') },
      }
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .onReady((cxt: NavDestinationContext) => this.handleOnReady(cxt))
    .onBackPressed(() => {
      if (!this.newContentPageState?.isBackPressed) {
        this.viewModel?.sendEvent(new PopEvent());
      }
      return true;
    })

  }

  tabSelectedIndexChange() {
    this.viewModel?.sendEvent(new InitContentNewEvent(this.tabSelectedIndexes[0]));
  }
}

@Builder
export function NewContentBuilder() {
  NewContentView()
}