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

import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, ColumnEnum, CommonConstants, LoadingMore, LoadingStatus, NoMore } from '@ohos/common';
import { CardStyleTypeEnum, SampleDetailParams } from '@ohos/commonbusiness';
import { SampleConstant } from '../common/SampleConstant';
import type { SampleCardData, SampleCategory, SampleContent } from '../model/SampleData';
import { PracticeEventType, PracticeViewModel } from '../viewmodel/PracticeViewModel';
import { BaseCategoryView } from './BaseCategoryView';
import { PictureAboveTextCard } from './PictureAboveTextCard';
import { PictureCard } from './PictureCard';
import { SampleListCard } from './SampleListCard';
import { SampleScrollCard } from './SampleScrollCard';

@Component({ freezeWhenInactive: true })
export struct CategorySamples {
  scroller: Scroller = new Scroller();
  viewModel: PracticeViewModel = PracticeViewModel.getInstance();
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop sampleCategory: SampleCategory;

  aboutToAppear(): void {
    if (!this.sampleCategory.sampleCards) {
      this.viewModel.sendEvent<SampleCategory>({
        type: PracticeEventType.LOAD_SAMPLE_LIST,
        param: this.sampleCategory,
      });
    }
  }

  jumpToDetail(currentIndex: number, sampleCardId: number) {
    this.viewModel.sendEvent<SampleDetailParams>({
      type: PracticeEventType.JUMP_DETAIL_DETAIL,
      param: { currentIndex, sampleCardId },
    });
  }

  @Builder
  CategoryContentViewBuilder() {
    GridRow({
      columns: { sm: ColumnEnum.SM, md: ColumnEnum.MD, lg: ColumnEnum.LG },
      gutter: { y: $r('sys.float.padding_level8'), x: $r('sys.float.padding_level8') },
      direction: GridRowDirection.Row,
    }) {
      Repeat(this.sampleCategory.sampleCards)
        .each((repeatItem: RepeatItem<SampleCardData>) => {
          GridCol({ span: CommonConstants.SPAN_4 }) {
            PictureAboveTextCard({ sampleCardData: repeatItem.item })
              .onClick(() => this.jumpToDetail(0, repeatItem.item.id))
          }
        })
        .key((item: SampleCardData) => item.id.toString())
        .templateId((item: SampleCardData) => item.cardStyleType.toString())
        .template(CardStyleTypeEnum.PICTURE_TO_SWIPER.toString(),
          (repeatItem: RepeatItem<SampleCardData>) => {
            GridCol({ span: CommonConstants.SPAN_4 }) {
              PictureAboveTextCard({ sampleCardData: repeatItem.item })
                .onClick(() => this.jumpToDetail(repeatItem.index, repeatItem.item.detailCardId))
            }
          })
        .template(CardStyleTypeEnum.PICTURE_ABOVE_TEXT.toString(),
          (repeatItem: RepeatItem<SampleCardData>) => {
            GridCol({ span: CommonConstants.SPAN_4 }) {
              PictureAboveTextCard({ sampleCardData: repeatItem.item })
                .onClick(() => this.jumpToDetail(0, repeatItem.item.id))
            }
          })
        .template(CardStyleTypeEnum.LIST.toString(), (repeatItem: RepeatItem<SampleCardData>) => {
          if (repeatItem.item.sampleContents.length > 2) {
            GridCol({
              span: { sm: CommonConstants.SPAN_4, md: CommonConstants.SPAN_8, lg: CommonConstants.SPAN_12 }
            }) {
              SampleScrollCard({
                sampleCardData: repeatItem.item,
                handleItemClick: (index: number, samples: SampleContent[]) => {
                  this.jumpToDetail(index, repeatItem.item.id);
                },
              })
                .margin({
                  left: new BreakpointType({
                    sm: SampleConstant.SCROLL_MARGIN_SM,
                    md: SampleConstant.SCROLL_MARGIN_MD,
                    lg: SampleConstant.SCROLL_MARGIN_LG,
                  }).getValue(this.globalInfoModel.currentBreakpoint),
                  right: new BreakpointType({
                    sm: SampleConstant.SCROLL_MARGIN_SM,
                    md: SampleConstant.SCROLL_MARGIN_MD,
                    lg: SampleConstant.SCROLL_MARGIN_LG,
                  }).getValue(this.globalInfoModel.currentBreakpoint),
                })
            }
            .clip(false)
          } else {
            GridCol({ span: CommonConstants.SPAN_4 }) {
              SampleListCard({
                sampleCardData: repeatItem.item,
                handleItemClick: (index: number, samples: SampleContent[]) => {
                  this.jumpToDetail(index, repeatItem.item.id);
                },
              })
            }
          }
        })
        .template(CardStyleTypeEnum.PICTURE.toString(), (repeatItem: RepeatItem<SampleCardData>) => {
          GridCol({ span: { sm: CommonConstants.SPAN_4, md: CommonConstants.SPAN_4, lg: CommonConstants.SPAN_8 } }) {
            PictureCard({ sampleCardData: repeatItem.item })
              .onClick(() => this.jumpToDetail(0, repeatItem.item.id))
          }
        })
      GridCol({ span: { sm: CommonConstants.SPAN_4, md: CommonConstants.SPAN_8, lg: CommonConstants.SPAN_12 } }) {
        Column() {
          if (this.sampleCategory.loadingModel.loadingMoreStatus === LoadingStatus.LOADING) {
            LoadingMore()
          } else if (this.sampleCategory.sampleCards.length > 0 && !this.sampleCategory.loadingModel.hasNextPage) {
            NoMore()
          }
        }
      }
      .padding({
        bottom: this.globalInfoModel.naviIndicatorHeight +
          (new BreakpointType({
            sm: CommonConstants.TAB_BAR_HEIGHT,
            md: CommonConstants.TAB_BAR_HEIGHT,
            lg: 0,
          }).getValue(this.globalInfoModel.currentBreakpoint)),
      })
    }
    .padding({
      left: new BreakpointType({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.currentBreakpoint),
      top: $r('sys.float.padding_level4')
    })
    .clip(false)
  }

  build() {
    BaseCategoryView({
      loadingModel: this.sampleCategory.loadingModel,
      contentView: () => {
        this.CategoryContentViewBuilder();
      },
      reloadData: () => {
        this.viewModel.sendEvent<SampleCategory>({
          type: PracticeEventType.LOAD_SAMPLE_LIST,
          param: this.sampleCategory,
        });
      },
    })
  }
}