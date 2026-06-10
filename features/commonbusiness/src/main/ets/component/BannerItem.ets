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
import { BreakpointType, ImageComponent, ProductSeriesEnum, StorageKey, } from '@ohos/common';
import type { BannerData } from '../model/BannerData';

@Reusable
@Component
export struct BannerItem {
  @Prop @Require widthBreakpoint: WidthBreakpoint;
  @State bannerData?: BannerData = undefined;

  aboutToReuse(params: Record<string, BannerData>): void {
    this.bannerData = params.bannerData;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      ImageComponent({
        src: this.bannerData?.mediaUrl,
        objectFit: ImageFit.Cover,
        alt: $r(undefined),
      })
        .backgroundColor(this.bannerData?.themeColor)
        .reuseId('bannerItem')
        .width('100%')
        .height('100%')
      Column() {
        Text(this.bannerData?.title)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(deviceInfo.productSeries === ProductSeriesEnum.VDE ? $r('sys.float.Subtitle_M') :
            $r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
        Text(this.bannerData?.subTitle)
          .margin({
            top: $r('sys.float.padding_level3'),
            bottom: $r('sys.float.padding_level2'),
          })
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
        Text(this.bannerData?.desc)
          .fontColor($r('sys.color.font_on_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
      }
      .padding({
        top: $r('sys.float.padding_level6'),
        left: (!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) &&
          this.widthBreakpoint === WidthBreakpoint.WIDTH_MD) ? $r('sys.float.padding_level12') :
          $r('sys.float.padding_level8'),
        right: (!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) &&
          this.widthBreakpoint === WidthBreakpoint.WIDTH_MD) ? $r('sys.float.padding_level12') :
          $r('sys.float.padding_level8'),
        bottom: AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? $r('sys.float.padding_level8') :
          new BreakpointType({
            sm: $r('sys.float.padding_level16'),
            md: $r('sys.float.padding_level16'),
            lg: $r('sys.float.padding_level8'),
          }).getValue(this.widthBreakpoint),
      })
      .height($r('app.float.banner_info_height'))
      .width('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
    }
    .renderGroup(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? $r('sys.float.corner_radius_level8') :
      new BreakpointType<Length>({
        sm: 0,
        md: 0,
        lg: $r('sys.float.corner_radius_level8'),
        xl: $r('sys.float.corner_radius_level8'),
      }).getValue(this.widthBreakpoint))
    .clip(true)
  }
}