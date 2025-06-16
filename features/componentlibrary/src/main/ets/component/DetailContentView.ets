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

import { curves } from '@kit.ArkUI';
import type { GlobalInfoModel } from '@ohos/common';
import {
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  WebNodeController,
  WebUtil,
} from '@ohos/common';
import { CodePreviewComponent } from './CodePreviewComponent';
import type { ConfigInterface } from '../componentdetailview/ComponentDetailConfig';
import { ComponentDetailPageVM, TopNavigationChangeEvent } from '../viewmodel/ComponentDetailPageVM';
import type { ComponentDetailState } from '../viewmodel/ComponentDetailState';
import type { RecommendData } from '../model/ComponentDetailData';
import { ComponentDetailManager } from '../viewmodel/ComponentDetailManager';
import { AttributeChangeArea } from './AttributeChangeArea';
import { RecommendListItem } from './RecommendListItem';
import { DetailPageConstant } from '../constant/DetailPageConstant';
import { CodePreviewJSUtil } from '../util/CodePreviewJSUtil';

const PREVIEW_HEIGHT_SM: number = DetailPageConstant.PREVIEW_HEIGHT_SM;

@Component
export struct DetailContentView {
  @ObjectLink componentDetailState: ComponentDetailState;
  @Prop componentName: string;
  @StorageProp('GlobalInfoModel') @Watch('handleBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get('GlobalInfoModel')!;
  @State isShowCodePreview: boolean = false;
  @State scaleValue: number = 1;
  @State showDivider: boolean = false;
  @State isShowTopDivider: boolean = false;
  @State webNodeController?: WebNodeController = new WebNodeController();
  scroller: Scroller = new Scroller();
  private viewModel?: ComponentDetailPageVM =
    ComponentDetailManager.getInstance().getDetailViewModel(this.componentName);
  private paddingToTop: number = 0;
  private paddingToBottom: number = 36;
  private detailConfig: Record<string, ConfigInterface> = AppStorage.get('componentDetailConfig')!

  @Builder
  textTip(text: ResourceStr) {
    Text(text)
      .fontSize($r('sys.float.Subtitle_S'))
      .fontColor($r('sys.color.font_secondary'))
      .fontWeight(FontWeight.Regular)
      .margin({
        top: $r('sys.float.padding_level10'),
        bottom: $r('sys.float.padding_level4'),
      })
  }

  aboutToAppear(): void {
    this.webNodeController = WebUtil.getWebNode(WebUtil.getComponentCodeUrl()) as WebNodeController;
    this.paddingToBottom =
      this.globalInfoModel.naviIndicatorHeight === 0 ? 36 : this.globalInfoModel.naviIndicatorHeight;
    // In EntryAbility, set decorHeight 0.
    const decorHeight: number =
      this.globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL ? this.globalInfoModel.decorHeight : 0;
    this.paddingToTop = this.globalInfoModel.statusBarHeight === decorHeight ? 0 : this.globalInfoModel.statusBarHeight;
  }

  aboutToDisappear(): void {
    const webController = WebUtil.getWebController(WebUtil.getComponentCodeUrl());
    webController?.scrollTo(0, 0);
  }

  jumpCodePreviewView() {
    const code = this.componentDetailState.code;
    const viewModel: ComponentDetailPageVM | undefined =
      ComponentDetailManager.getInstance().getDetailViewModel(this.componentName);
    this.webNodeController?.remove();
    this.webNodeController = undefined;
    const toFullScreenMethod: string = 'toFullScreen()';
    CodePreviewJSUtil.codeViewRunJS(toFullScreenMethod);
    animateTo({ curve: curves.interpolatingSpring(0, 1, 195, 23) }, () => {
      viewModel?.jumpToCodePreview(code, () => {
        this.backFromCodePreview();
      });
    });
  }

  backFromCodePreview(): void {
    this.webNodeController = WebUtil.getWebNode(WebUtil.getComponentCodeUrl()) as WebNodeController;
    this.webNodeController.add();
  }

  handleBreakPointChange() {
    this.viewModel?.sendEvent(new TopNavigationChangeEvent(this.globalInfoModel.currentBreakpoint ===
    BreakpointTypeEnum.SM ? false : this.isShowTopDivider));
  }

  build() {
    Flex({
      direction: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? FlexDirection.Column :
      FlexDirection.Row,
    }) {
      Column() {
        this.textTip($r('app.string.preview'))
        Column() {
          (this.detailConfig[this.componentName] as ConfigInterface).previewComponentBuilder.builder({
            descriptor: this.componentDetailState.descriptor,
          })
        }
        .margin({
          top: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? 0 : $r('sys.float.padding_level4'),
        })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(new BreakpointType({
          sm: DetailPageConstant.PREVIEW_SUB_HEIGHT_SM,
          md: (this.globalInfoModel.deviceHeight - (CommonConstants.NAVIGATION_HEIGHT + this.paddingToTop +
          this.paddingToBottom) - DetailPageConstant.TEXT_TIP_HEIGHT),
          lg: (this.globalInfoModel.deviceHeight - (CommonConstants.NAVIGATION_HEIGHT + this.paddingToTop +
          this.paddingToBottom) - DetailPageConstant.TEXT_TIP_HEIGHT),
        }).getValue(this.globalInfoModel.currentBreakpoint))
        .borderRadius($r('sys.float.corner_radius_level8'))
      }
      .padding({
        top: CommonConstants.NAVIGATION_HEIGHT + this.globalInfoModel.statusBarHeight + DetailPageConstant.SPACE_NORMAL,
        bottom: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? $r('sys.float.padding_level6') : 0,
        left: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.globalInfoModel.currentBreakpoint),
        right: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level4'),
          lg: $r('sys.float.padding_level6'),
        }).getValue(this.globalInfoModel.currentBreakpoint),
      })
      .size(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? { width: '100%' } : { width: '50%' })
      .alignItems(HorizontalAlign.Start)

      if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM && this.showDivider) {
        Divider()
          .width('100%')
      }
      Scroll(this.scroller) {
        Column({ space: DetailPageConstant.SPACE_NORMAL }) {
          if (this.componentDetailState.attributes.length !== 0) {
            this.textTip($r('app.string.changeAttributes'))
            AttributeChangeArea({
              attributes: this.componentDetailState.attributes,
              componentName: this.componentName,
            })
          }
          this.textTip($r('app.string.code'))
          CodePreviewComponent({
            webNodeController: this.webNodeController,
            code: this.componentDetailState.code,
            componentName: this.componentName,
            pageContainer: false,
            pushPage: () => {
              this.jumpCodePreviewView();
            },
          })
            .width('100%')
            .height($r('app.float.code_preview_height'))
            .geometryTransition(CommonConstants.CODE_PREVIEW_GEOMETRY_ID, { follow: true })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .clip(true)
            .margin({
              top: (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ||
                this.componentDetailState.attributes.length !== 0) ? 0 : $r('sys.float.padding_level4'),
            })
            .onClick(() => {
              this.jumpCodePreviewView();
            })
          if (this.componentDetailState.recommends.length > 0) {
            this.textTip($r('app.string.recommend'))
            Column() {
              ForEach(this.componentDetailState.recommends, (item: RecommendData, index: number) => {
                if (index !== 0) {
                  Divider()
                    .color($r('sys.color.comp_divider'))
                    .width('100%')
                    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
                }
                RecommendListItem({ itemData: item })
                  .height(DetailPageConstant.ATTRIBUTE_ITEM_HEIGHT)
              }, (_item: RecommendData) => _item.id?.toString())
            }
            .backgroundColor($r('sys.color.comp_background_primary'))
            .width('100%')
            .borderRadius($r('sys.float.corner_radius_level8'))
          }
        }
        .margin({
          top: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? 0 :
          $r('sys.float.padding_level4'),
        })
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: new BreakpointType({
            sm: 0,
            md: CommonConstants.NAVIGATION_HEIGHT + this.globalInfoModel.statusBarHeight,
            lg: CommonConstants.NAVIGATION_HEIGHT + this.globalInfoModel.statusBarHeight,
          }).getValue(this.globalInfoModel.currentBreakpoint),
          bottom: this.paddingToBottom,
        })
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onDidScroll(() => {
        if (this.scroller.currentOffset().yOffset > DetailPageConstant.SCROLL_OFFSET_Y) {
          if (!this.showDivider) {
            this.showDivider = true;
          }
          this.isShowTopDivider = this.globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.SM ? true : false;
          this.viewModel?.sendEvent(new TopNavigationChangeEvent(this.isShowTopDivider));
        } else if (this.scroller.currentOffset().yOffset <= DetailPageConstant.SCROLL_OFFSET_Y) {
          this.showDivider = false;
          this.isShowTopDivider = false;
          this.viewModel?.sendEvent(new TopNavigationChangeEvent(this.isShowTopDivider));
        }
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_ONLY,
        scrollBackward: NestedScrollMode.SELF_ONLY,
      })
      .size(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ?
        {
          width: '100%',
          height: (this.globalInfoModel.deviceHeight - PREVIEW_HEIGHT_SM -
            (CommonConstants.NAVIGATION_HEIGHT + this.paddingToTop)),
        } :
        {
          width: '50%',
          height: this.globalInfoModel.deviceHeight,
        })
      .padding({
        left: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level4'),
          lg: $r('sys.float.padding_level6'),
        }).getValue(this.globalInfoModel.currentBreakpoint),
        right: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.globalInfoModel.currentBreakpoint),
      })
    }
    .width('100%')
    .height('100%')
  }
}