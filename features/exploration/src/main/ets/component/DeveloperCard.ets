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

import { deviceInfo } from '@kit.BasicServicesKit';
import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, BreakpointTypeEnum, CommonConstants, ProductSeriesEnum } from '@ohos/common';
import type { DiscoverContent } from '../model/DiscoverData';
import { DeveloperItem } from './DeveloperItem';

const DEVELOPER_ITEM_RATIO = 960 / 1312;
const DEVELOPER_ITEM_RATIO_VERDE = 240 / 408;

@Component
export struct DeveloperCard {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop @Require discoverContents: DiscoverContent[];
  handleItemClick?: Function;

  build() {
    Swiper() {
      Repeat(this.discoverContents)
        .each((repeatItem: RepeatItem<DiscoverContent>) => {
          Column() {
            DeveloperItem({ discoverContent: repeatItem.item })
              .onClick(() => {
                this.handleItemClick?.(repeatItem.item);
              })
          }
          .padding({
            left: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ?
            $r('sys.float.padding_level8') : 0,
            right: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ?
            $r('sys.float.padding_level8') : 0,
          })
        })
    }
    .size(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ?
      {
        height: ((this.globalInfoModel.deviceWidth - CommonConstants.SPACE_32) *
          (deviceInfo.productSeries === ProductSeriesEnum.VDE ? DEVELOPER_ITEM_RATIO_VERDE : DEVELOPER_ITEM_RATIO) +
        CommonConstants.SPACE_16) * this.discoverContents.length
      } :
      { height: $r('app.float.list_card_height') })
    .effectMode(EdgeEffect.None)
    .loop(false)
    .indicator(false)
    .disableSwipe(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM)
    .vertical(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM)
    .prevMargin(new BreakpointType<Length>({
      sm: 0,
      md: $r('sys.float.padding_level6'),
      lg: CommonConstants.SPACE_16 + CommonConstants.TAB_BAR_WIDTH,
      xl: CommonConstants.SPACE_16,
    }).getValue(this.globalInfoModel.currentBreakpoint))
    .nextMargin(new BreakpointType<Length>({
      sm: 0,
      md: $r('sys.float.padding_level6'),
      lg: $r('sys.float.padding_level8'),
    }).getValue(this.globalInfoModel.currentBreakpoint))
    .displayCount(
      new BreakpointType({
        sm: this.discoverContents.length,
        md: CommonConstants.LANE_MD,
        lg: CommonConstants.LANE_LG,
      }).getValue(this.globalInfoModel.currentBreakpoint)
    )
    .itemSpace(new BreakpointType({
      sm: CommonConstants.SPACE_16,
      md: CommonConstants.SPACE_12,
      lg: CommonConstants.SPACE_16,
    }).getValue(this.globalInfoModel.currentBreakpoint))
  }
}