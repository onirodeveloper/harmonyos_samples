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

import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  Logger,
  StorageKey,
  TRACK_KEY,
  TrackServiceData,
  WebSheetBuilder,
  WebUrlType,
  WebUtil,
  ShareUtil,
  ActionName,
  InteractionTypeEnum,
} from '@ohos/common';
import { SampleConstant } from '../common/SampleConstant';
import { SampleDetailConstant } from '../constant/CommonConstants';
import {
  BindSheetEvent,
  ChangeCardStatusEvent,
  LoadSampleEvent,
  SampleDetailPageVM,
  SetOverflowStatusEvent,
  TerminateTaskEvent,
} from '../viewmodel/SampleDetailPageVM';
import type { SampleCardData } from '../viewmodel/SampleDetailState';

const TAG = '[SampleCard]';

@Component
export struct SampleCard {
  viewModel: SampleDetailPageVM = SampleDetailPageVM.getInstance();
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State backIconBgColor: ResourceColor =
    this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? Color.Transparent :
      $r('sys.color.comp_background_tertiary');
  @Consume currentIndex: number;
  @Prop sampleIndex: number;
  @ObjectLink sampleCard: SampleCardData;
  private lastClickTime: number = 0;

  aboutToAppear(): void {
    WebUtil.createWebNode(this.sampleCard.originalUrl, this.getUIContext(), NestedScrollMode.SELF_ONLY);
  }

  aboutToDisappear(): void {
    WebUtil.removeNode(this.sampleCard.originalUrl);
  }

  @Builder
  TitleComponent() {
    Row() {
      Text($r('app.string.sample_code'))
        .maxLines(1)
        .height($r('app.float.samplename_height'))
        .lineHeight($r('app.float.cardtitle_lineheight'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_S'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Button() {
        SymbolGlyph($r('sys.symbol.share'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize($r('sys.float.Title_M'))
      }
      .height($r('app.float.back_button_height'))
      .aspectRatio(1)
      .backgroundColor(this.backIconBgColor)
      .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
        $r('sys.float.corner_radius_level4') : '50%')
      .onClick(() => this.handleShare())
      .customProperty(TRACK_KEY, {
        interactionContent: this.sampleCard.title,
        actionName: ActionName.SOURCE_CODE_SHARE,
        interactionType: InteractionTypeEnum.SAMPLE,
      } as TrackServiceData)
      .onHover((isHover: boolean) => {
        this.backIconBgColor = isHover ? $r('sys.color.comp_background_tertiary') : Color.Transparent;
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  @Builder
  overlayBuilder() {
    Stack()
      .height($r('app.float.overlay_height'))
      .width('100%')
      .linearGradient({
        direction: GradientDirection.Top,
        colors: [[$r('sys.color.ohos_id_color_background_transparent'), 0],
          [$r('sys.color.ohos_id_background_secondary'), SampleDetailConstant.LINEAR_GRADIENT_END]]
      })
      .visibility(this.sampleCard.isOverflow && !this.sampleCard.cardOpenStatus ? Visibility.Visible :
        Visibility.Hidden)
      .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
      .hitTestBehavior(HitTestMode.None)
  }

  build() {
    Column() {
      Column() {
        Text(this.sampleCard.title)
          .maxLines(SampleDetailConstant.TITLE_MAXLINE)
          .height($r('app.float.samplename_height'))
          .lineHeight($r('app.float.cardtitle_lineheight'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Subtitle_L'))
          .margin({ bottom: $r('sys.float.padding_level1') })
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.sampleCard.desc)
          .maxLines(this.sampleCard.cardOpenStatus ? SampleDetailConstant.SUBTITLE_OPEN_MAXLINE :
            SampleDetailConstant.SUBTITLE_MAXLINE)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .lineHeight($r('app.float.cardsubtitle_lineheight'))
          .fontColor($r('sys.color.font_secondary'))
          .wordBreak(WordBreak.BREAK_ALL)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .overlay(this.overlayBuilder())
          .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
      }
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldValue, newValue) => {
        if (newValue.width !== oldValue.width) {
          this.viewModel.sendEvent(new SetOverflowStatusEvent(this.getUIContext(), newValue, this.sampleIndex));
        }
      })

      Row() {
        SymbolGlyph(this.sampleCard.cardOpenStatus ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
          .fontSize($r('app.float.expand_icon_size'))
          .fontColor([$r('sys.color.icon_tertiary')])
          .margin({
            right: $r('sys.float.padding_level1'),
          })
        Text(this.sampleCard.cardOpenStatus ? $r('app.string.card_collapse') : $r('app.string.card_expand'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
          .lineHeight($r('app.float.expand_line_height'))
      }
      .width('100%')
      .height($r('app.float.expand_area_height'))
      .justifyContent(FlexAlign.Center)
      .visibility(this.sampleCard.isOverflow ? Visibility.Visible : Visibility.Hidden)
      .margin({
        top: this.sampleCard.cardOpenStatus && this.sampleCard.isOverflow ? $r('sys.float.padding_level4') :
          $r('sys.float.padding_level0'),
      })
      .onClick(() => {
        this.viewModel.sendEvent(new ChangeCardStatusEvent(this.sampleIndex));
      })

      Row() {
        Button($r('app.string.read_code'),
          {
            type: ButtonType.Normal,
            buttonStyle: ButtonStyleMode.NORMAL,
            controlSize: ControlSize.SMALL,
          })
          .cardButtonStyle($r('sys.color.comp_background_tertiary'), $r('sys.color.background_emphasize'),
            this.globalInfoModel.widthBreakpoint)
          .onClick(() => {
            this.viewModel.sendEvent(new BindSheetEvent(this.sampleIndex, true));
          })
          .bindSheet(this.sampleCard.bindSheetShow,
            WebSheetBuilder(this.sampleCard.originalUrl, WebUrlType.GITCODE), {
              title: () => this.TitleComponent(),
              preferType: SheetType.CENTER,
              height: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
                ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
                CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
              width: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
                CommonConstants.SHEET_WIDTH_XL :
                undefined,
              onWillDismiss: () => {
                WebUtil.getWebNode(this.sampleCard.originalUrl)?.remove();
                this.viewModel.sendEvent(new BindSheetEvent(this.sampleIndex, false));
              },
              onWillSpringBackWhenDismiss: () => {
                Logger.info(TAG,
                  `The springBack is not registered, causing the half-modal sheet to lack bounce-back behavior when pulled down.`);
              }
            })
          .customProperty(TRACK_KEY, {
            interactionContent: this.sampleCard.title,
            actionName: ActionName.SOURCE_CODE_VIEW,
            interactionType: InteractionTypeEnum.SAMPLE,
          } as TrackServiceData)

        Blank()
          .width(new BreakpointType({
            sm: CommonConstants.SPACE_16,
            md: CommonConstants.SPACE_16,
            lg: CommonConstants.SPACE_24,
          }).getValue(this.globalInfoModel.widthBreakpoint))

        if (this.sampleCard.downloading && this.currentIndex === this.sampleIndex &&
          (this.sampleCard.downloadProgress >= 0)) {
          Progress({
            value: SampleDetailConstant.PROGRESS_START,
            total: SampleDetailConstant.PROGRESS_FINISH,
            type: ProgressType.Capsule,
          })
            .value(this.sampleCard.downloadProgress)
            .layoutWeight(1)
            .borderRadius(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
              $r('sys.float.corner_radius_level4') : '50%')
            .height($r('app.float.progress_height'))
            .color($r('sys.color.background_emphasize'))
            .backgroundColor($r('sys.color.background_primary'))
            .style({
              borderColor: $r('sys.color.background_emphasize'),
              borderWidth: $r('sys.float.border_larger'),
              content: `${this.sampleCard.downloadProgress}%`,
              font: {
                size: $r('sys.float.Body_S'),
                style: FontStyle.Normal,
                weight: FontWeight.Medium,
              },
              fontColor: $r('sys.color.font_primary'),
            })
            .onClick(() => {
              this.handleClickWithRateLimit(() => {
                this.viewModel.sendEvent(new TerminateTaskEvent(this.sampleIndex));
              })
            })
        } else {
          Button(this.sampleCard.installed ? $r('app.string.experience_sample') : $r('app.string.download_sample'),
            {
              type: ButtonType.Normal,
              buttonStyle: ButtonStyleMode.NORMAL,
              controlSize: ControlSize.SMALL,
            })
            .cardButtonStyle($r('sys.color.background_emphasize'), $r('sys.color.font_on_primary'),
              this.globalInfoModel.widthBreakpoint)
            .onClick(() => {
              this.handleClickWithRateLimit(() => {
                this.viewModel.sendEvent(new LoadSampleEvent());
              })
            })
            .customProperty(TRACK_KEY, {
              interactionContent: this.sampleCard.title,
              actionName: ActionName.EXPERIENCE_CLICK,
              interactionType: InteractionTypeEnum.SAMPLE,
            } as TrackServiceData)
        }
      }
      .width('100%')
      .height($r('app.float.card_button_height'))
      .justifyContent(FlexAlign.SpaceAround)
      .margin({
        top: $r('sys.float.padding_level4'),
      })
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .clip(true)
    .animation({
      duration: SampleDetailConstant.ANIMATION_DURATION,
      curve: Curve.EaseOut,
    })
    .padding({
      top: $r('sys.float.padding_level8'),
      bottom: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? $r('sys.float.padding_level12') :
        $r('sys.float.padding_level8'),
      left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? $r('sys.float.padding_level16') :
        $r('sys.float.padding_level8'),
      right: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ? $r('sys.float.padding_level16') :
        $r('sys.float.padding_level8'),
    })
  }

  private handleShare(): void {
    if (canIUse('SystemCapability.Collaboration.SystemShare')) {
      ShareUtil.shareData({
        utd: utd.UniformDataType.HYPERLINK,
        content: this.sampleCard.originalUrl,
        title: this.sampleCard.title,
        description: this.sampleCard.originalUrl
      });
    }
  }

  private handleClickWithRateLimit(handleClickEvent: () => void): void {
    const currentTime = new Date().getTime();
    if (currentTime - this.lastClickTime >= SampleConstant.MIN_CLICK_INTERVAL) {
      handleClickEvent();
      this.lastClickTime = currentTime;
    }
  }
}

@Extend(Button)
function cardButtonStyle(backgroundColor: ResourceColor, fontColor: ResourceColor, widthBreakpoint: WidthBreakpoint) {
  .borderRadius(widthBreakpoint === WidthBreakpoint.WIDTH_XL ? $r('sys.float.corner_radius_level4') : '50%')
  .layoutWeight(1)
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Medium)
  .fontColor(fontColor)
  .backgroundColor(backgroundColor)
  .controlSize(ControlSize.NORMAL)
}