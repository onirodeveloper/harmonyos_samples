/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { CommonConstants } from '@ohos/common';

@Component
export struct QRCodeSheet {
  @Link bindQRCode: boolean;
  @Prop sampleURL: string;
  @Prop sampleTitle: String;

  build() {
    Column() {
    }
    .bindSheet(this.bindQRCode, this.qrCodeContent, {
      title: { title: $r('app.string.view_source') },
      preferType: SheetType.CENTER,
      height: SheetSize.FIT_CONTENT,
      onWillDisappear: () => {
        this.bindQRCode = false;
      },
      shouldDismiss: () => {
        this.bindQRCode = false;
        return true;
      }
    })
  }

  @Builder
  qrCodeContent() {
    Column() {
      Text($r('app.string.scan_text', this.sampleTitle))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: CommonConstants.SPACE_32
        })

      Column() {
        QRCode(this.sampleURL)
          .height($r('app.float.qrcode_sheet_qrcode_size'))
          .width($r('app.float.qrcode_sheet_qrcode_size'))
      }
      .backgroundColor(Color.White)
      .padding($r('app.float.qrcode_sheet_qrcode_padding'))
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: $r('app.float.qrcode_sheet_qrcode_bottom_margin') })
      .borderRadius($r('app.float.qrcode_sheet_qrcode_border_radius'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .margin({
      bottom: $r('app.float.qrcode_sheet_bottom_margin')
    })
    .padding({
      left: CommonConstants.SPACE_32,
      right: CommonConstants.SPACE_32,
    })
    .alignItems(HorizontalAlign.Center)
  }
}


