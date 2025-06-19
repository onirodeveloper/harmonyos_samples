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

import { Popup } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointTypeEnum, GlobalInfoModel, Logger, PreferenceManager } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { CommonStorageKey } from '../../common/entity/CommonStorageKey';

const TAG: string = '[AIImageComponent]';

@Component
export struct AIImageComponent {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @State imagePixelMap?: image.PixelMap = undefined;
  @State showPopup: boolean = true;
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;

  async aboutToAppear() {
    PreferenceManager.getInstance().getValue<boolean>(CommonStorageKey.KEY_MATTING_TIP).then((value) => {
      this.showPopup = value ?? true;
    });
    this.imagePixelMap = await this.getPixmapFromMedia($r('app.media.image_ai'));
  }

  aboutToDisappear(): void {
    this.imagePixelMap?.release();
  }

  @Builder
  MyPopup() {
    Row() {
      Popup({
        title: {
          text: $r('app.string.aiMatting'),
        },
        message: {
          text: $r('app.string.aiMatting_tip')
        },
        showClose: true,
        onClose: () => {
          this.showPopup = false;
        },
        buttons: [
          {
            text: $r('app.string.confirmTip'),
            action: () => {
              this.showPopup = false;
            },
          },
          {
            text: $r('app.string.cancelTip'),
            action: () => {
              PreferenceManager.getInstance().setValue(CommonStorageKey.KEY_MATTING_TIP, false);
              this.showPopup = false;
            },
          }
        ],
      })
    }
    .onKeyPreIme((keyEvent: KeyEvent) => {
      if ((keyEvent?.keyText === 'KEYCODE_DPAD_RIGHT' || keyEvent?.keyText === 'KEYCODE_DPAD_LEFT') &&
        keyEvent.type === KeyType.Down) {
        return true;
      }
      return false;
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.imagePixelMap ?? $r('app.media.image_ai'))
        .enableAnalyzer(true)
        .width(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? '100%' : '90%')
        .height(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? '100%' : this.imageHeight)
        .objectFit(this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.SM ? ImageFit.Fill : ImageFit.Contain)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .draggable(false)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.imageWidth = newValue.width as number;
          this.imageHeight = this.imageWidth * 0.56 as number;
        })
        .bindPopup(this.showPopup, {
          builder: this.MyPopup(),
          width: $r('app.float.popup_width_large'),
          backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          radius: ($r('sys.float.corner_radius_level4')),
          offset: { y: DetailPageConstant.IMAGE_POPUP_OFFSET_Y },
          placement: Placement.Bottom,
          showInSubWindow: true,
          onStateChange: (event) => {
            if (!event.isVisible) {
              this.showPopup = false;
            }
          },
          focusable: true,
        })
    }
    .width('100%')
    .height('100%')
  }

  private async getPixmapFromMedia(resource: Resource) {
    let createPixelMap: image.PixelMap;
    try {
      const unit8Array = await getContext(this)?.resourceManager?.getMediaContent({
        bundleName: resource.bundleName,
        moduleName: resource.moduleName,
        id: resource.id,
      });
      const imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
      createPixelMap = await imageSource.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
      });
      await imageSource.release();
      this.imagePixelMap?.release();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Get pixmapFromMedia error, the code is ${error.code}, the message is ${error.message}`);
      return;
    }
    return createPixelMap;
  }
}