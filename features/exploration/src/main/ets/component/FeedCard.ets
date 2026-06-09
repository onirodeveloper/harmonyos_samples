/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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
  CommonConstants,
  GlobalInfoModel,
  StorageKey,
  TRACK_KEY,
  TrackNode,
  TrackServiceData,
  HdsUtil,
  InteractionTypeEnum,
  ActionName,
} from '@ohos/common';
import type { DiscoverContent } from '../model/DiscoverData';
import { FeedItem } from './FeedItem';

@Component
export struct FeedCard {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @Prop @Require discoverContents: DiscoverContent[];
  handleItemClick?: Function;

  build() {
    Swiper() {
      Repeat(this.discoverContents)
        .each((repeatItem: RepeatItem<DiscoverContent>) => {
          TrackNode() {
            FeedItem({ discoverContent: repeatItem.item })
              .customProperty(TRACK_KEY, {
                interactionContent: repeatItem.item.title,
                interactionType: InteractionTypeEnum.ARTICLE,
                actionName: ActionName.ARTICLE_CLICK,
              } as TrackServiceData)
              .onClick(() => {
                this.handleItemClick?.(repeatItem.item);
              })
          }
        })
        .key((item: DiscoverContent) => item.id.toString())
    }
    .cachedCount(3)
    .effectMode(EdgeEffect.None)
    .loop(false)
    .indicator(false)
    .prevMargin(new BreakpointType<Length>({
      sm: CommonConstants.SPACE_8,
      md: CommonConstants.SPACE_12,
      lg: (HdsUtil.isSupportNewMaterialApi() || AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) ?
        CommonConstants.SPACE_16 : CommonConstants.SPACE_16 + CommonConstants.TAB_BAR_WIDTH,
    }).getValue(this.globalInfoModel?.widthBreakpoint))
    .nextMargin(new BreakpointType<Length>({
      sm: CommonConstants.SPACE_8,
      md: CommonConstants.SPACE_12,
      lg: CommonConstants.SPACE_16,
      xl: CommonConstants.SPACE_16,
    }).getValue(this.globalInfoModel?.widthBreakpoint))
    .displayCount(this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? CommonConstants.LANE_MD :
      CommonConstants.LANE_LG)
    .itemSpace(new BreakpointType({
      sm: CommonConstants.SPACE_8,
      md: CommonConstants.SPACE_12,
      lg: CommonConstants.SPACE_16,
      xl: CommonConstants.SPACE_16,
    }).getValue(this.globalInfoModel?.widthBreakpoint))
  }
}