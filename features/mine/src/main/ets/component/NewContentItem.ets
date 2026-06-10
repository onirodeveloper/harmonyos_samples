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
  ActionName,
  BreakpointType,
  CommonConstants,
  EmptyContentView,
  GlobalInfoModel,
  HmosListItem,
  InteractionTypeEnum,
  StorageKey,
  TRACK_KEY,
  TrackNode,
  TrackServiceData
} from '@ohos/common';
import { CardTypeEnum } from '@ohos/commonbusiness';
import { NewContentData } from '../model/NewContentData';
import { JumpToPage, NewContentVM } from '../viewmodel/NewContentVM';

@Component
export struct NewContentItem {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @Prop @Require contentData: NewContentData[] = [];
  @Prop @Require emptyDescription: Resource;
  private viewModel: NewContentVM = NewContentVM.getInstance();

  @Builder
  listFooterBuilder() {
    Row() {
      Text($r('app.string.mine_no_more'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .margin({
          top: $r('sys.float.padding_level24'),
          bottom: CommonConstants.SPACE_24 + this.globalInfoModel?.naviIndicatorHeight,
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
  }

  build() {
    Column() {
      if (this.contentData.length === 0) {
        EmptyContentView($r('app.media.noInstallationPackage'), this.emptyDescription)
      } else {
        List() {
          ListItemGroup() {
            ForEach(this.contentData, (item: NewContentData) => {
              ListItem() {
                TrackNode() {
                  HmosListItem({
                    title: item.title,
                    subTitle: item.subTitle,
                    itemHeight: $r('app.float.content_item_height'),
                    buttonTitle: item.contentType !== CardTypeEnum.ARTICLE ? $r('app.string.view') : undefined,
                    widthBreakpoint: this.globalInfoModel?.widthBreakpoint,
                    handleClickAction: () => {
                      this.viewModel.sendEvent(new JumpToPage(item));
                    },
                  })
                    .customProperty(TRACK_KEY, {
                      interactionContent: item.title,
                      interactionType: item.contentType === CardTypeEnum.COMPONENT ? InteractionTypeEnum.COMPONENT :
                        item.contentType === CardTypeEnum.SAMPLE ? InteractionTypeEnum.SAMPLE :
                          InteractionTypeEnum.ARTICLE,
                      actionName: item.contentType === CardTypeEnum.COMPONENT ? ActionName.COMPONENT_CLICK :
                        item.contentType === CardTypeEnum.SAMPLE ? ActionName.SAMPLE_CLICK : ActionName.ARTICLE_CLICK
                    } as TrackServiceData)
                }
              }
              .padding({
                left: $r('sys.float.padding_level2'),
                right: $r('sys.float.padding_level2'),
              })
              .height($r('app.float.content_item_height'))
            })
          }
          .divider({
            strokeWidth: $r('app.float.mine_divider'),
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level6'),
            endMargin: $r('sys.float.padding_level6'),
          })
          .padding({
            top: $r('sys.float.padding_level2'),
            bottom: $r('sys.float.padding_level2'),
          })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))

          ListItemGroup({ footer: this.listFooterBuilder })
        }
        .lanes(new BreakpointType<number>({
          sm: 1,
          md: 2,
          lg: 2,
        }).getValue(this.globalInfoModel.widthBreakpoint))
        .edgeEffect(EdgeEffect.Spring)
        .scrollBarWidth(0)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
      }
    }
    .padding({ top: $r('sys.float.padding_level8') })
    .size({
      width: CommonConstants.FULL_PERCENT,
      height: CommonConstants.FULL_PERCENT,
    })
  }
}