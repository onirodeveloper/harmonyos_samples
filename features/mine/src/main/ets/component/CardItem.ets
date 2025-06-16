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
import { BreakpointTypeEnum, CommonConstants } from '@ohos/common';
import { AboutBuilder } from '../view/AboutView';

@Component
export struct CardItem {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @Prop isShow: boolean;
  textContent?: Resource;
  symbolSrc?: Resource;
  onclick: Function = () => {
  };
  onClose: Function = () => {
  };

  build() {
    Row() {
      SymbolGlyph(this.symbolSrc)
        .fontSize($r('sys.float.Title_M'))
        .fontColor([$r('sys.color.icon_secondary')])
      Text(this.textContent)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('sys.float.padding_level8') })
      Blank()
      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor([$r('sys.color.icon_fourth')])
    }
    .width('100%')
    .height($r('app.float.mine_listItem_height'))
    .onClick(() => {
      this.onclick();
    })
    .bindSheet(this.isShow, AboutBuilder(), {
      preferType: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? SheetType.BOTTOM :
      SheetType.CENTER,
      title: { title: $r('app.string.about') },
      height: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
        ((this.globalInfoModel.deviceHeight - this.globalInfoModel.decorHeight) *
        CommonConstants.SHEET_HEIGHT_RATIO_XL) : SheetSize.LARGE,
      width: this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? CommonConstants.SHEET_WIDTH_XL :
        undefined,
      onWillDisappear: () => {
        this.onClose();
      },
    })
  }
}