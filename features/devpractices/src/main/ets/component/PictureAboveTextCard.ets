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

import { BreakpointType, BreakpointTypeEnum, CommonConstants, GlobalInfoModel } from '@ohos/common';
import type { SampleCardData, SampleContent } from '../model/SampleData';
import { TagLabel } from './TagLabel';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { CardStyleTypeEnum } from '@ohos/commonbusiness';

const IMAGE_SIZE: number = 40;
const TAG_PADDING: number = 32;

@Component
export struct PictureAboveTextCard {
  @StorageProp('GlobalInfoModel') @Watch('calculateTagMaxWidth') globalInfoModel: GlobalInfoModel =
    AppStorage.get('GlobalInfoModel')!;
  @StorageProp('systemColorMode') systemColorMode: ConfigurationConstant.ColorMode = AppStorage.get('systemColorMode')!;
  @Prop sampleCardData: SampleCardData;
  @State sampleContent?: SampleContent = undefined;
  @State maxWidth: number = 0;

  aboutToAppear(): void {
    this.sampleContent = this.sampleCardData.sampleContents?.[0];
    this.calculateTagMaxWidth();
  }

  calculateTagMaxWidth() {
    let barWidth: number = new BreakpointType({
      sm: 0,
      md: 0,
      lg: CommonConstants.TAB_BAR_WIDTH,
      xl: CommonConstants.SIDE_BAR_WIDTH,
    }).getValue(this.globalInfoModel.currentBreakpoint);
    const paddingVal = new BreakpointType({
      sm: CommonConstants.SPACE_16,
      md: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? CommonConstants.SPACE_32 :
          CommonConstants.SPACE_24,
      lg: CommonConstants.SPACE_32,
      xl: CommonConstants.SPACE_32,
    }).getValue(this.globalInfoModel.currentBreakpoint);
    const currentWidth: number = this.globalInfoModel.deviceWidth - barWidth;
    const count: number = new BreakpointType({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3,
    }).getValue(this.globalInfoModel.currentBreakpoint);
    const gutter = CommonConstants.SPACE_16;
    this.maxWidth = Math.floor((currentWidth - paddingVal * 2 - gutter * (count - 1)) / count) - TAG_PADDING -
      IMAGE_SIZE - CommonConstants.SPACE_16;
  }

  build() {
    Column() {
      Row() {
        Image($rawfile(this.sampleContent?.mediaUrl))
          .alt($r('app.media.img_placeholder'))
          .height('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .draggable(true)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .clip(true)
      .layoutWeight(1)
      .padding({ top: $r('sys.float.padding_level16'), bottom: $r('sys.float.padding_level8') })

      Row() {
        Column() {
          Text(this.sampleContent?.title)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.sampleCardData.cardStyleType === CardStyleTypeEnum.PICTURE_TO_SWIPER ?
            $r('app.color.card_font_primary_color') : $r('sys.color.font_primary'))
          TagLabel({
            maxWidth: this.maxWidth,
            tags: this.sampleContent?.tags || [],
            cardStyleType: this.sampleCardData.cardStyleType
          })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button({ type: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? ButtonType.ROUNDED_RECTANGLE :
                ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([this.sampleCardData.cardStyleType === CardStyleTypeEnum.PICTURE_TO_SWIPER ?
            $r('app.color.icon_secondary_color') : $r('sys.color.icon_secondary')])
            .fontSize($r('sys.float.Title_M'))
        }
        .margin({ left: $r('sys.float.padding_level6') })
        .height($r('app.float.card_button_height'))
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        top: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level10'),
      })
      .height($r('app.float.picture_card_content_height'))
      .backgroundColor(this.sampleCardData.cardStyleType === CardStyleTypeEnum.PICTURE_TO_SWIPER ?
      $r('app.color.card_color') : $r('sys.color.comp_background_secondary'))
    }
    .clip(true)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .backgroundImage($rawfile(this.sampleCardData.cardImage))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .height($r('app.float.picture_card_height'))
  }
}