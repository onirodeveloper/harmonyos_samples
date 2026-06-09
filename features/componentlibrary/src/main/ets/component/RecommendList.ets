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
  CommonConstants,
  StorageKey,
  HmosListItem,
} from '@ohos/common';
import type { RecommendData } from '../model/ComponentDetailData';

@Component
export struct RecommendList {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @Prop recommends: RecommendData[];
  @State showSheet: boolean = false;
  @State selectedItem?: RecommendData = undefined;

  build() {
    Column() {
      ForEach(this.recommends, (item: RecommendData, index: number) => {
        if (index !== 0) {
          Divider()
            .color($r('sys.color.comp_divider'))
            .width('100%')
            .padding({
              left: $r('sys.float.padding_level6'),
              right: $r('sys.float.padding_level6'),
            })
        }
        HmosListItem({
          prefixResource: item.articleType === 1 ? $r('sys.symbol.doc_text') : $r('sys.symbol.paintpalette'),
          prefixColor: $r('sys.color.icon_emphasize'),
          title: item.title,
          handleClickAction: () => {
            this.selectedItem = item;
            WebUtil.createWebNode(item.url, undefined, NestedScrollMode.SELF_ONLY);
            WebUtil.addNode(item.url);
            this.showSheet = true;
          }
        })
      }, (_item: RecommendData) => _item.url?.toString())
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding($r('sys.float.padding_level2'))
    .width('100%')
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .bindSheet(this.showSheet, WebSheetBuilder(this.selectedItem?.url ?? '', WebUrlType.HARMONYOS), {
      showClose: true,
      onDisappear: () => {
        this.showSheet = false;
        WebUtil.getWebNode(this.selectedItem?.url)?.remove();
      },
      preferType: SheetType.CENTER,
      height: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
        ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
        CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
      width: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? CommonConstants.SHEET_WIDTH_XL :
        undefined,
      title: { title: this.selectedItem?.title },
    })
  }
}