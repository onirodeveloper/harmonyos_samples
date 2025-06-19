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

import { HandwriteComponent, HandwriteController } from '@kit.Penkit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointTypeEnum, GlobalInfoModel, Logger } from '@ohos/common';
import { ComponentDetailManager } from '../../../viewmodel/ComponentDetailManager';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';

const TAG: string = '[HandWritingComponent]';
const BUTTON_OFFSET: number = 16;

@Component
export struct HandWritingComponent {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  private controller: HandwriteController = new HandwriteController();
  private initPath: string = 'savePath';
  private closeButtonTop: number = BUTTON_OFFSET;

  aboutToAppear(): void {
    // Close button offset.
    if (this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.LG ||
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      this.closeButtonTop = DetailPageConstant.PEN_CLOSE_TOP;
    } else {
      this.closeButtonTop = BUTTON_OFFSET;
    }
  }

  aboutToDisappear() {
    // Invoke the saving interface when the HandWriteDemo exits.
    try {
      this.controller?.save(this.initPath);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `HandwriteController save error, the code is ${error.code}, the message is ${error.message}`);
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
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
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize($r('sys.float.ohos_id_textfield_icon_size'))
        }
        .width($r('sys.float.ohos_id_button_height'))
        .height($r('sys.float.ohos_id_button_height'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin({ top: this.closeButtonTop + this.globalInfoModel.statusBarHeight, right: $r('sys.float.padding_level8') })
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