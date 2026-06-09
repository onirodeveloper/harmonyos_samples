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

import {
  BreakpointType,
  ColumnEnum,
  CommonConstants,
  GlobalInfoModel,
  InteractionTypeEnum,
  LoadingMore,
  LoadingStatus,
  NoMore,
  StorageKey,
} from '@ohos/common';
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
  viewModel: PracticeViewModel = PracticeViewModel.getInstance();
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @Prop sampleCategory: SampleCategory;
  @State @Watch('getMarginByBreakpoint') currentBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_LG;
  @State itemMargin: Length = 0;

  aboutToAppear(): void {
    if (!this.sampleCategory.sampleCards || this.sampleCategory.sampleCards.length === 0) {
      this.viewModel.sendEvent<SampleCategory>({
        type: PracticeEventType.LOAD_SAMPLE_LIST,
        param: this.sampleCategory,
      });
    }
    this.getMarginByBreakpoint();
  }

  getMarginByBreakpoint() {
    this.itemMargin = new BreakpointType({
      sm: SampleConstant.SCROLL_MARGIN_SM,
      md: SampleConstant.SCROLL_MARGIN_MD,
      lg: 0
    }).getValue(this.currentBreakpoint);
  }

  jumpToDetail(currentIndex: number, sampleContent: SampleContent, categoryName: string) {
    this.viewModel.sendEvent<SampleDetailParams>({
      type: PracticeEventType.JUMP_DETAIL_DETAIL,
      param: {
        title: sampleContent.title,
        currentIndex,
        cardId: sampleContent.cardId,
        interactionType: InteractionTypeEnum.SAMPLE,
        unionId: sampleContent.unionId,
        id: sampleContent.id,
        categoryName,
      },
    });
  }

  @Builder
  CategoryContentViewBuilder() {
    GridRow({
      columns: { sm: ColumnEnum.SM, md: ColumnEnum.MD, lg: ColumnEnum.LG },
      gutter: {
        y: $r('sys.float.padding_level8'),
        x: new BreakpointType({
          sm: $r('sys.float.padding_level8'),
          md: $r('sys.float.padding_level16'),
          lg: $r('sys.float.padding_level8')
        }).getValue(this.currentBreakpoint),
      },
      direction: GridRowDirection.Row,
      breakpoints: { reference: BreakpointsReference.ComponentSize }
    }) {
      Repeat(this.sampleCategory.sampleCards)
        .each((repeatItem: RepeatItem<SampleCardData>) => {
          GridCol({ span: CommonConstants.SPAN_4 }) {
            PictureAboveTextCard({
              sampleCardData: repeatItem.item,
              widthBreakPoint: this.globalInfoModel.widthBreakpoint,
              handleItemClick: (index: number, sample: SampleContent) => {
                this.jumpToDetail(sample.unionId ? repeatItem.index : index, sample, this.sampleCategory.categoryName);
              },
            })
              .margin({
                left: this.itemMargin,
                right: this.itemMargin,
              })
          }
          .clip(false)
        })
        .key((item: SampleCardData) => item.id.toString())
        .templateId((item: SampleCardData) => item.styleType.toString())
        .template(CardStyleTypeEnum.PICTURE_ABOVE_TEXT.toString(),
          (repeatItem: RepeatItem<SampleCardData>) => {
            GridCol({ span: CommonConstants.SPAN_4 }) {
              PictureAboveTextCard({
                sampleCardData: repeatItem.item,
                widthBreakPoint: this.globalInfoModel.widthBreakpoint,
                handleItemClick: (index: number, sample: SampleContent) => {
                  this.jumpToDetail(sample.unionId ? repeatItem.index : index, sample,
                    this.sampleCategory.categoryName);
                },
              })
                .margin({
                  left: this.itemMargin,
                  right: this.itemMargin,
                })
            }
            .clip(false)
          })
        .template(CardStyleTypeEnum.LIST.toString(), (repeatItem: RepeatItem<SampleCardData>) => {
          if (repeatItem.item.sampleContents.length > 2) {
            GridCol({
              span: { sm: CommonConstants.SPAN_4, md: CommonConstants.SPAN_8, lg: CommonConstants.SPAN_12 }
            }) {
              SampleScrollCard({
                sampleCardData: repeatItem.item,
                handleItemClick: (index: number, sample: SampleContent) => {
                  this.jumpToDetail(index, sample, this.sampleCategory.categoryName);
                },
              })
                .margin({
                  left: SampleConstant.SCROLL_MARGIN_LG,
                  right: SampleConstant.SCROLL_MARGIN_LG,
                })
            }
            .clip(false)
          } else {
            GridCol({ span: CommonConstants.SPAN_4 }) {
              SampleListCard({
                sampleCardData: repeatItem.item,
                handleItemClick: (index: number, sample: SampleContent) => {
                  this.jumpToDetail(index, sample, this.sampleCategory.categoryName);
                },
              })
                .margin({
                  left: this.itemMargin,
                  right: this.itemMargin,
                })
            }
            .clip(false)
          }
        })
        .template(CardStyleTypeEnum.PICTURE.toString(), (repeatItem: RepeatItem<SampleCardData>) => {
          GridCol({ span: { sm: CommonConstants.SPAN_4, md: CommonConstants.SPAN_4, lg: CommonConstants.SPAN_8 } }) {
            PictureCard({
              sampleCardData: repeatItem.item,
              handleItemClick: (index: number, sample: SampleContent) => {
                this.jumpToDetail(sample.unionId ? repeatItem.index : index, sample, this.sampleCategory.categoryName);
              },
            })
              .margin({
                left: this.itemMargin,
                right: this.itemMargin,
              })
          }
          .clip(false)
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
          (AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? 0 : CommonConstants.TAB_BAR_HEIGHT),
      })
    }
    .padding({
      left: -SampleConstant.SCROLL_MARGIN_LG,
      right: -SampleConstant.SCROLL_MARGIN_LG,
      top: $r('sys.float.padding_level4'),
    })
    .onBreakpointChange((breakpoints: string) => {
      this.currentBreakpoint =
        SampleConstant.BREAKPOINTS.includes(breakpoints) ? SampleConstant.BREAKPOINTS.indexOf(breakpoints) :
          WidthBreakpoint.WIDTH_XL;
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