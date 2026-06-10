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
import {
  BreakpointType,
  CommonConstants,
  GlobalInfoModel,
  ImageComponent,
  ImageUtil,
  StorageKey,
  TRACK_KEY,
  TrackNode,
  TrackServiceData,
  HdsUtil,
  InteractionTypeEnum,
  ActionName,
} from '@ohos/common';
import { TagTipLabel } from '@ohos/commonbusiness';
import type { SampleCardData, SampleContent } from '../model/SampleData';
import { TagLabel } from './TagLabel';

const IMAGE_SIZE: number = 40;
const TAG_PADDING: number = 32;

@Component
export struct PictureAboveTextCard {
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('calculateTagMaxWidth') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @Prop sampleCardData: SampleCardData;
  @Prop @Require widthBreakPoint: WidthBreakpoint;
  @State sampleContent?: SampleContent = undefined;
  @State maxWidth: number = 0;
  handleItemClick?: Function;

  aboutToAppear(): void {
    this.sampleContent = this.sampleCardData.sampleContents?.[0];
    this.calculateTagMaxWidth();
  }

  calculateTagMaxWidth() {
    let barWidth: number = AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? CommonConstants.SIDE_BAR_WIDTH :
      new BreakpointType({
        sm: 0,
        md: 0,
        lg: HdsUtil.isSupportNewMaterialApi() ? 0 : CommonConstants.TAB_BAR_WIDTH,
      }).getValue(this.globalInfoModel.widthBreakpoint);
    const paddingVal = new BreakpointType({
      sm: CommonConstants.SPACE_16,
      md: CommonConstants.SPACE_24,
      lg: CommonConstants.SPACE_32,
      xl: CommonConstants.SPACE_32,
    }).getValue(this.globalInfoModel.widthBreakpoint);
    const currentWidth: number = this.globalInfoModel.deviceWidth - barWidth;
    const count: number = new BreakpointType({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3,
    }).getValue(this.globalInfoModel.widthBreakpoint);
    this.maxWidth = Math.max(0,
      (Math.floor((currentWidth - paddingVal * 2 - CommonConstants.SPACE_16 * (count - 1)) / count) - TAG_PADDING -
        IMAGE_SIZE - CommonConstants.SPACE_16));
  }

  build() {
    TrackNode() {
      Stack({ alignContent: Alignment.TopStart }) {
        TagTipLabel({
          tags: this.sampleContent?.tagIds ?? [],
          newSymbol: $r('app.media.big_new'),
        })
          .margin({
            top: $r('sys.float.padding_level3'),
            left: $r('sys.float.padding_level3'),
          })
          .width(CommonConstants.FULL_PERCENT)
        Column() {
          Row() {
            ImageComponent({
              src: this.sampleContent?.mediaInfoList[0]?.mediaUrl,
              objectFit: ImageFit.Contain,
              alt: $r('app.media.img_placeholder'),
            })
              .height('100%')
              .width('100%')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .clip(true)
          .layoutWeight(1)
          .padding({
            top: $r('sys.float.padding_level16'),
            bottom: $r('sys.float.padding_level8'),
            left: $r('sys.float.padding_level16'),
            right: $r('sys.float.padding_level16'),
          })

          Row() {
            Column() {
              Text(this.sampleContent?.title)
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor(this.sampleCardData.unionId === 1 ? $r('app.color.card_font_primary_color') :
                  $r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              TagLabel({
                maxWidth: this.maxWidth,
                tags: this.sampleContent?.tags || [],
                cardStyleType: this.sampleCardData.styleType,
                unionId: this.sampleCardData.unionId
              })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Button({ type: ButtonType.Normal }) {
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontColor([this.sampleCardData.unionId === 1 ? $r('app.color.icon_secondary_color') :
                  $r('sys.color.icon_secondary')])
                .fontSize($r('sys.float.Title_M'))
            }
            .margin({ left: $r('sys.float.padding_level6') })
            .height($r('app.float.card_button_height'))
            .aspectRatio(1)
            .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
              $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
          }
          .padding({
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
            top: $r('sys.float.padding_level6'),
            bottom: $r('sys.float.padding_level10'),
          })
          .height($r('app.float.picture_card_content_height'))
          .backgroundColor(this.sampleCardData.unionId === 1 ? $r('app.color.card_color') :
            $r('sys.color.comp_background_secondary'))
        }
      }
      .onClick(() => {
        this.handleItemClick?.(0, this.sampleContent);
      })
      .clip(true)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .backgroundImage(this.sampleCardData.unionId === 1 ? ImageUtil.getImgResource(this.sampleCardData.image): '')
      .backgroundImageSize({ width: '100%', height: '100%' })
      .clickEffect({ level: ClickEffectLevel.MIDDLE })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .height($r('app.float.picture_card_height'))
      .customProperty(TRACK_KEY, {
        interactionContent: this.sampleContent?.title,
        interactionType: InteractionTypeEnum.SAMPLE,
        actionName: ActionName.SAMPLE_CLICK,
      } as TrackServiceData)
    }
  }
}