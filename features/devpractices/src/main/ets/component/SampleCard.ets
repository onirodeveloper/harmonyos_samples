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

import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { systemShare } from '@kit.ShareKit';
import {
  Logger,
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  WebSheetBuilder,
  WebUrlType,
  WebUtil,
  type GlobalInfoModel,
} from '@ohos/common';
import { SampleDetailConstant } from '../constant/CommonConstants';
import { BindSheetEvent, SampleDetailPageVM, LoadSampleEvent } from '../viewmodel/SampleDetailPageVM';
import type { SampleCardData } from '../viewmodel/SampleDetailState';

const TAG = '[SampleCard]';

@Component
export struct SampleCard {
  viewModel: SampleDetailPageVM = SampleDetailPageVM.getInstance();
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Consume currentIndex: number;
  @Prop sampleIndex: number;
  @ObjectLink sampleCard: SampleCardData;
  @State backIconBgColor: ResourceColor =
    this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? Color.Transparent :
    $r('sys.color.comp_background_tertiary');

  aboutToAppear(): void {
    WebUtil.createWebNode(this.sampleCard.originalUrl, this.getUIContext(), NestedScrollMode.SELF_ONLY);
  }

  aboutToDisappear(): void {
    WebUtil.removeNode(this.sampleCard.originalUrl);
  }

  private handleShare(): void {
    if (canIUse('SystemCapability.Collaboration.SystemShare')) {
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.HYPERLINK,
        content: this.sampleCard.originalUrl,
        title: this.sampleCard.title,
        description: this.sampleCard.originalUrl
      });
      let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      let context = getContext(this) as common.UIAbilityContext;
      controller.show(context, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DEFAULT
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Sample link sharing error. Code: ${error.code}, message: ${error.message}`);
      });
    }
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
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.share'))
          .fontColor([$r('sys.color.icon_primary')])
          .fontSize($r('sys.float.Title_M'))
      }
      .height($r('app.float.back_button_height'))
      .aspectRatio(1)
      .backgroundColor(this.backIconBgColor)
      .onClick(() => this.handleShare())
      .onHover((isHover: boolean) => {
        this.backIconBgColor = isHover ? $r('sys.color.comp_background_tertiary') : Color.Transparent;
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  build() {
    Column() {
      Text(this.sampleCard.title)
        .maxLines(1)
        .height($r('app.float.samplename_height'))
        .lineHeight($r('app.float.cardtitle_lineheight'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Subtitle_L'))
        .margin({ bottom: $r('sys.float.padding_level1') })
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.sampleCard.desc)
        .maxLines(SampleDetailConstant.SUBTITLE_MAXLINE)
        .height($r('app.float.sampledesc_height'))
        .fontSize($r('sys.float.Subtitle_S'))
        .fontWeight(FontWeight.Regular)
        .lineHeight($r('app.float.cardsubtitle_lineheight'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          bottom: $r('sys.float.padding_level12'),
        })
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({
        space: new BreakpointType({
          sm: CommonConstants.SPACE_16,
          md: CommonConstants.SPACE_16,
          lg: CommonConstants.SPACE_24,
        }).getValue(this.globalInfoModel.currentBreakpoint),
      }) {
        Button($r('app.string.read_code'))
          .cardButtonStyle($r('sys.color.comp_background_tertiary'), $r('sys.color.background_emphasize'))
          .onClick(() => {
            this.viewModel.sendEvent(new BindSheetEvent(this.sampleIndex, true));
          })
          .bindSheet(this.sampleCard.bindSheetShow,
            WebSheetBuilder(this.sampleCard.originalUrl, WebUrlType.GITEE), {
              title: () => this.TitleComponent(),
              preferType: SheetType.CENTER,
              height: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
                ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
                CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
              width: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? CommonConstants.SHEET_WIDTH_XL :
                undefined,
              onWillDisappear: () => {
                WebUtil.getWebNode(this.sampleCard.originalUrl)?.remove();
                this.viewModel.sendEvent(new BindSheetEvent(this.sampleIndex, false));
              },
              onWillSpringBackWhenDismiss: () => {
                Logger.info(TAG,
                  `The springBack is not registered, causing the half-modal sheet to lack bounce-back behavior when pulled down.`);
              }
            })

        if (this.sampleCard.downloading && this.currentIndex === this.sampleIndex &&
          (this.sampleCard.downloadProgress >= 0)) {
          Progress({
            value: SampleDetailConstant.PROGRESS_START,
            total: SampleDetailConstant.PROGRESS_FINISH,
            type: ProgressType.Capsule,
          })
            .value(this.sampleCard.downloadProgress)
            .layoutWeight(1)
            .borderRadius($r('sys.float.corner_radius_level7'))
            .height($r('app.float.progress_height'))
            .color($r('sys.color.background_emphasize'))
            .backgroundColor($r('sys.color.comp_background_primary_contrary'))
            .style({
              borderColor: $r('sys.color.background_emphasize'),
              borderWidth: $r('sys.float.border_small'),
              content: `${this.sampleCard.downloadProgress}%`,
              font: { size: $r('sys.float.Subtitle_S'), style: FontStyle.Normal, weight: FontWeight.Medium },
              fontColor: Color.Black,
            })
        } else {
          Button(this.sampleCard.installed ? $r('app.string.experience_sample') : $r('app.string.download_sample'))
            .cardButtonStyle($r('sys.color.background_emphasize'), $r('sys.color.font_on_primary'))
            .onClick(() => {
              this.viewModel.sendEvent(new LoadSampleEvent());
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .height($r('app.float.sample_card_height'))
    .alignItems(HorizontalAlign.Start)
    .clip(true)
    .margin({
      top: new BreakpointType({
        sm: $r('app.float.margin_36'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level12'),
      }).getValue(this.globalInfoModel.currentBreakpoint),
    })
    .padding({
      top: $r('sys.float.padding_level9'),
      bottom: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ? $r('sys.float.padding_level12') :
      $r('sys.float.padding_level8'),
      left: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ? $r('sys.float.padding_level16') :
      $r('sys.float.padding_level8'),
      right: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ? $r('sys.float.padding_level16') :
      $r('sys.float.padding_level8'),
    })
  }
}

@Extend(Button)
function cardButtonStyle(backgroundColor: ResourceColor, fontColor: ResourceColor) {
  .layoutWeight(1)
  .fontSize($r('sys.float.Subtitle_S'))
  .fontWeight(FontWeight.Medium)
  .fontColor(fontColor)
  .backgroundColor(backgroundColor)
  .controlSize(ControlSize.NORMAL)
  .borderRadius($r('sys.float.corner_radius_level7'))
}