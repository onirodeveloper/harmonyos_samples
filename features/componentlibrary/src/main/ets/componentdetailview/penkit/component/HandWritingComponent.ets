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

import { BusinessError } from '@kit.BasicServicesKit';
import { HandwriteComponent, HandwriteController } from '@kit.Penkit';
import { GlobalInfoModel, Logger, StorageKey } from '@ohos/common';
import { ComponentDetailManager } from '../../../viewmodel/ComponentDetailManager';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';

const TAG: string = '[HandWritingComponent]';
const BUTTON_OFFSET: number = 16;

@Component
export struct HandWritingComponent {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  private controller: HandwriteController = new HandwriteController();
  private initPath: string = 'savePath';
  private closeButtonTop: number = BUTTON_OFFSET;
  @State backIconBgColor: ResourceColor =
    this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? Color.Transparent :
    $r('sys.color.comp_background_tertiary');

  aboutToAppear(): void {
    // Close button offset.
    if (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
      this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) {
      this.closeButtonTop = DetailPageConstant.PEN_CLOSE_TOP;
    } else {
      this.closeButtonTop = BUTTON_OFFSET;
    }
  }

  aboutToDisappear() {
    // Invoke the saving interface when the HandWriteDemo exits.
    try {
      this.controller?.save(this.initPath)
        .catch((error: BusinessError) => {
          Logger.error(TAG, `HandwriteController save failed, cause code ${error.code}, message ${error.message}`);
        });
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `HandwriteController save error, the code is ${error.code}, the message is ${error.message}`);
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        HandwriteComponent({
          handwriteController: this.controller,
          onInit: () => {
            try {
              this.controller?.load(this.initPath);
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              Logger.error(TAG,
                `HandwriteController load error, the code is ${error.code}, the message is ${error.message}`);
            }
          }
        })
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize($r('sys.float.ohos_id_textfield_icon_size'))
        }
        .height($r('app.float.back_button_height'))
        .aspectRatio(1)
        .backgroundColor(this.backIconBgColor)
        .onHover((isHover: boolean) => {
          this.backIconBgColor = isHover ? $r('sys.color.comp_background_tertiary') : Color.Transparent;
        })
        .margin({
          top: this.globalInfoModel.statusBarHeight + 10,
          left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? $r('sys.float.padding_level12') :
                $r('sys.float.padding_level8')
        })
        .onClick(() => {
          ComponentDetailManager.getInstance().getDetailViewModel('Penkit')?.pop();
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
  }
}

@Builder
export function PenKitViewBuilder() {
  HandWritingComponent()
}