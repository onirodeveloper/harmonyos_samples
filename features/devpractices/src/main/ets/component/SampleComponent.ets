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

import { emitter } from '@kit.BasicServicesKit';
import {
  BreakpointType,
  ColumnEnum,
  CommonConstants,
  FeedbackDomain,
  FeedbackSheet,
  GlobalInfoModel,
  ImageComponent,
  PageContext,
  PageEnum,
  StorageKey,
} from '@ohos/common';
import { SampleDetailData } from '../viewmodel/SampleDetailState';
import { ImagePreviewParam } from '../view/ImagePreview';
import { SampleCard } from './SampleCard';
import { MediaInfo } from '../model/SampleData';

@Component
export struct SampleComponent {
  @State swiperMargin: number = 0;
  @ObjectLink singleSampleData: SampleDetailData;
  @Prop @Require sampleIndex: number;
  @Prop showIndicator: boolean = false;
  @Prop @Require widthBreakpoint: WidthBreakpoint;
  @State bindFeedbackSheet: boolean = false;
  @State imageIndex: number = 0;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  private containerWidth: number = 0;
  private cardWidth: number = 0;

  aboutToAppear(): void {
    emitter.on(CommonConstants.BIND_SHEET_OPEN_EVENT + this.sampleIndex, () => {
      this.bindFeedbackSheet = true;
    });
  }

  aboutToDisappear(): void {
    emitter.off(CommonConstants.BIND_SHEET_OPEN_EVENT + this.sampleIndex);
  }

  private calculateMargin() {
    if (this.containerWidth > 0 && this.cardWidth > 0) {
      let margin =
        this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? (this.containerWidth - this.cardWidth) / 2 :
          (this.containerWidth - this.cardWidth) / 2 - CommonConstants.SPACE_12;
      this.swiperMargin = margin > 0 ? margin : 0;
    }
  }

  jumpToImagePreview(url: string) {
    const pathStack = this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
      AppStorage.get<PageContext>(StorageKey.SAMPLE_PAGE_CONTEXT) :
      AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT);
    const imagePreviewParam: ImagePreviewParam = {
      url: url,
    };
    pathStack?.openPage({
      routerName: PageEnum.IMAGE_PREVIEW,
      param: imagePreviewParam,
    }, false);
  }

  build() {
    Column() {
      Column() {
        FeedbackSheet({
          bindFeedback: this.bindFeedbackSheet,
          feedbackInitParams: {
            uid: '1',
            domain: FeedbackDomain.SAMPLE,
            domainId: this.singleSampleData.sampleCard.sampleId,
            domainTitle: this.singleSampleData.sampleCard.title,
            likeReasonsResource: $r('app.strarray.sample_like_reason_list'),
            dislikeReasonsResource: $r('app.strarray.sample_dislike_reason_list'),
          }
        })
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
            $r('sys.float.padding_level32') : $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.widthBreakpoint),
        right: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
            $r('sys.float.padding_level32') : $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.widthBreakpoint),
      })

      Swiper() {
        ForEach(this.singleSampleData.mediaInfoList, (mediaInfo: MediaInfo) => {
          Row() {
            ImageComponent({
              src: mediaInfo.mediaUrl,
              objectFit: ImageFit.Contain,
            })
              .width('90%')
              .height('90%')
          }
          .margin({
            top: CommonConstants.SPACE_28,
            bottom: CommonConstants.SPACE_28,
          })
          .justifyContent(FlexAlign.Center)
          .borderRadius(16)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .onClick(() => {
            this.jumpToImagePreview(mediaInfo.mediaUrl)
          })
        })
      }
      .nestedScroll(this.singleSampleData.mediaInfoList.length <= 1 ? SwiperNestedScrollMode.SELF_FIRST :
        SwiperNestedScrollMode.SELF_ONLY)
      .layoutWeight(1)
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .cachedCount(3)
      .effectMode(EdgeEffect.None)
      .loop(true)
      .indicator(false)
      .index($$this.imageIndex)
      .prevMargin(this.swiperMargin)
      .nextMargin(this.swiperMargin)
      .itemSpace(CommonConstants.SPACE_12)
      .margin({
        bottom: this.widthBreakpoint === WidthBreakpoint.WIDTH_MD &&
          this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
          $r('app.float.display_bottom_padding') : $r('sys.float.padding_level0'),
        top: this.widthBreakpoint === WidthBreakpoint.WIDTH_MD &&
          this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
          $r('app.float.display_top_padding') : $r('sys.float.padding_level0')
      })

      Column() {
        GridRow({
          columns: {
            sm: ColumnEnum.SM,
            md: this.widthBreakpoint === WidthBreakpoint.WIDTH_MD &&
              this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ? ColumnEnum.SM :
              ColumnEnum.MD,
            lg: ColumnEnum.LG
          },
          gutter: {
            x: {
              sm: $r('sys.float.padding_level6'),
              md: $r('sys.float.padding_level6'),
              lg: $r('sys.float.padding_level8'),
            },
          },
        }) {
          GridCol({
            span: {
              sm: CommonConstants.SPAN_4,
              md: this.widthBreakpoint === WidthBreakpoint.WIDTH_MD &&
                this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
                CommonConstants.SPAN_4 : CommonConstants.SPAN_6,
              lg: CommonConstants.SPAN_8
            },
            offset: {
              sm: 0,
              md: this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ? 0 : 1,
              lg: 2
            },
          }) {
            SampleCard({
              sampleCard: this.singleSampleData.sampleCard,
              sampleIndex: this.sampleIndex,
            })
          }
          .onAreaChange((oldValue: Area, newValue: Area) => {
            const newCardWidth = newValue.width as number;
            if (Math.abs(this.cardWidth - newCardWidth) > 1) {
              this.cardWidth = newCardWidth;
              this.calculateMargin();
            }
          })
        }
      }
      .margin({
        bottom: this.showIndicator ? $r('sys.float.padding_level16') : $r('sys.float.padding_level8'),
      })
      .padding({
        left: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
            $r('sys.float.padding_level32') : $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.widthBreakpoint),
        right: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
            $r('sys.float.padding_level32') : $r('sys.float.padding_level12'),
          lg: $r('sys.float.padding_level16'),
        }).getValue(this.widthBreakpoint),
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .height('100%')
    .width('100%')
    .padding({
      top: $r('sys.float.padding_level4'),
      bottom: this.widthBreakpoint === WidthBreakpoint.WIDTH_MD &&
        this.globalInfoModel.heightBreakpoint === HeightBreakpoint.HEIGHT_LG ?
        $r('app.float.tablet_vertical_padding') : $r('sys.float.padding_level0'),
    })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      const newContainerWidth = newValue.width as number;
      if (Math.abs(this.containerWidth - newContainerWidth) > 1) {
        this.containerWidth = newContainerWidth;
        this.calculateMargin();
      }
    })
  }
}