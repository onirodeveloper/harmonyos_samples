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
  WebUtil,
  WebSheetBuilder,
  WebUrlType,
  GlobalInfoModel,
  BreakpointTypeEnum,
  CommonConstants,
} from '@ohos/common';
import { DetailPageConstant } from '../constant/DetailPageConstant';
import type { RecommendData } from '../model/ComponentDetailData';

@Component
export struct RecommendListItem {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop itemData: RecommendData;
  @State showSheet: boolean = false;

  build() {
    Row() {
      SymbolGlyph(this.itemData.articleType === 1 ? $r('sys.symbol.doc_text') : $r('sys.symbol.paintpalette'))
        .fontSize($r('app.float.symbol_size_large'))
        .margin({ right: $r('sys.float.padding_level8') })
        .fontColor([$r('sys.color.icon_emphasize')])
      Column() {
        Text(this.itemData.title).fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.font_primary'))
        Text(this.itemData.subTitle).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_tertiary'))
      }
      .width('70%')
      .alignItems(HorizontalAlign.Start)

      Blank()
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.icon_secondary')])
        .fontSize($r('app.float.symbol_size_large'))
        .bindSheet(this.showSheet, WebSheetBuilder(this.itemData.url, WebUrlType.HARMONYOS), {
          showClose: true,
          onDisappear: () => {
            this.showSheet = false;
            WebUtil.getWebNode(this.itemData.url)?.remove();
          },
          preferType: SheetType.CENTER,
          height: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
            ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
            CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
          width: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? CommonConstants.SHEET_WIDTH_XL :
            undefined,
          title: { title: this.itemData.title },
        })
    }
    .onClick(() => {
      WebUtil.createWebNode(this.itemData.url, undefined, NestedScrollMode.SELF_ONLY);
      WebUtil.addNode(this.itemData.url);
      this.showSheet = true;
    })
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(DetailPageConstant.ATTRIBUTE_ITEM_HEIGHT)
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }
}