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
import { sensor } from '@kit.SensorServiceKit';
import { formInfo, formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import {
  fluffyList,
  codeList,
  delayParams,
  LIVE_CARD_RATIO,
  PicTranslateData,
  FLUFFY_SENSOR_RATE,
  MONITOR_SENSOR_RATE,
  BOTH_Z_SENSOR_RATE,
  GYROSCOPE_REFRESHING_INTERVAL,
  WidgetImageOffsetData,
  WidgetLiveCardCodeComponent,
  WidgetViewModel
} from '@ohos/widgetcommon';

const TAG: string = '[LiveForm]';
let storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct Index {
  sensor: sensor.Sensor | null = null;
  @State xTranslate: number = 0.0;
  @State yTranslate: number = 0.0;
  @State zTranslate: number = 0.0;
  @State fluffyHeight: number = 85;
  @State fluffyWidth: number = this.fluffyHeight * (16 / 9);
  @State fluffyIsReady: boolean = false;
  @State monitorHeight: number = 85;
  @State monitorWidth: number = this.monitorHeight;
  @State fluffyIdx: number = 1;
  @State fluffyAnimateIntervalId: number | null = null;
  @State fluffyImage: string = fluffyList[this.fluffyIdx];

  private formWidth: number = 0;
  private formHeight: number = 0;
  private formLeft: number = 0;
  private formBottom: number = 0;
  private formRadius: number = 0;

  async aboutToAppear(): Promise<void> {
    Logger.info(TAG, `Index aboutToAppear`);
    let localStorage: LocalStorage | undefined = this.getUIContext()?.getSharedLocalStorage();
    let formRect = localStorage?.get<formInfo.Rect>('formRect');
    let borderRadius = localStorage?.get<number>('radius');
    this.formWidth = formRect ? formRect.width : 0;
    this.formHeight = formRect ? formRect.height : 0;
    this.formLeft = formRect ? formRect.left : 0;
    this.formBottom = formRect ? formRect.height * LIVE_CARD_RATIO - formRect.top - formRect.height : 0;
    this.formRadius = borderRadius ? borderRadius : 0;

    try {
      const sensorList = sensor.getSensorListSync();
      sensorList.forEach((_sensor) => {
        if (_sensor.sensorId === sensor.SensorId.GYROSCOPE) {
          Logger.info(TAG, `set sensor: ${JSON.stringify(_sensor)}`);
          this.sensor = _sensor;
        }
      });
    } catch (err) {
      Logger.error(TAG, `Error @aboutToAppear: ${err}`);
    }
    if (this.sensor != null) {
      try {
        sensor.on(sensor.SensorId.GYROSCOPE, (theSensor: sensor.GyroscopeResponse) => {
          Logger.debug(TAG,
            `Succeeded in obtaining sensor data:\n x: ${theSensor.x}, y: ${theSensor.y}, z: ${theSensor.z}`);
          // Attention: x,y for Sensor are y, x for phone screen!
          this.xTranslate += theSensor.y;
          this.yTranslate += theSensor.x;
          this.zTranslate += theSensor.z;
          this.xTranslate = Math.max(this.xTranslate, PicTranslateData.TRANSLATE_X_MIN);
          this.xTranslate = Math.min(this.xTranslate, PicTranslateData.TRANSLATE_X_MAX);
          this.yTranslate = Math.max(this.yTranslate, PicTranslateData.TRANSLATE_Y_MIN);
          this.yTranslate = Math.min(this.yTranslate, PicTranslateData.TRANSLATE_Y_MAX);
          this.zTranslate = Math.max(this.zTranslate, PicTranslateData.TRANSLATE_Z_MIN);
          this.zTranslate = Math.min(this.zTranslate, PicTranslateData.TRANSLATE_Z_MAX);
          this.fluffyWidth = this.fluffyHeight * (16 / 9) + (this.xTranslate * 0);
          this.monitorWidth = this.monitorHeight - (this.xTranslate * 0);
        }, { interval: GYROSCOPE_REFRESHING_INTERVAL });
      } catch (err) {
        let error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Failed to invoke on. Code: ${error.code}, message: ${error.message}`);
      }
    } else {
      Logger.info(TAG, `Failed to get gyroscope on this device.`);
    }
    this.setAnimeInterval(200);
  }

  private setAnimeInterval(interval: number) {
    if (this.fluffyAnimateIntervalId) {
      return;
    }

    this.fluffyAnimateIntervalId = setInterval(() => {
      this.switchFluffyToNextFrame()
    }, interval);
  }

  private switchFluffyToNextFrame(toFrame?: number) {
    if (toFrame) {
      this.fluffyIdx = toFrame % fluffyList.length;
    } else {
      this.fluffyIdx = (this.fluffyIdx + 1) % fluffyList.length;
      this.fluffyImage = fluffyList[this.fluffyIdx];
    }
    Logger.debug(TAG, `Interval for Animation. ${this.fluffyIdx}, ${this.fluffyImage}`);
  }

  aboutToDisappear(): void {
    Logger.info(TAG, `ExtensionPage -> aboutToDisappear`);
    clearInterval(this.fluffyAnimateIntervalId);
    this.fluffyAnimateIntervalId = null;
    this.fluffyIsReady = false;
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      RelativeContainer() {
        Image($r('app.media.Fluffy_BG'))
          .height(`100%`)
          .borderRadius(this.formRadius)

        Image($r(`app.media.${this.fluffyImage}`))
          .objectFit(ImageFit.Fill)
          .height(`${this.fluffyHeight}%`)
          .width(`${this.fluffyWidth}%`)
          .alignRules(WidgetViewModel.setAlignRules('center', VerticalAlign.Center, 'start', HorizontalAlign.Start))
          .translate({
            x: (FLUFFY_SENSOR_RATE * this.xTranslate) + WidgetImageOffsetData.FLUFFY_POSITION.x +
              (BOTH_Z_SENSOR_RATE * this.zTranslate),
            y: WidgetImageOffsetData.FLUFFY_POSITION.y,
          })
          .onAppear(() => {
            Logger.info(TAG, `Image.onAppear ${this.fluffyIdx}, ${this.fluffyImage}`);
          })
          .onComplete(() => {
            this.fluffyIsReady = true;
          })
        // Show monitor only after fluffy is shown
        if (this.fluffyIsReady) {
          Image($r('app.media.Monitor'))
            .objectFit(ImageFit.Fill)
            .height(`${this.monitorHeight}%`)
            .width(`${this.monitorWidth}%`)
            .alignRules(WidgetViewModel.setAlignRules('center', VerticalAlign.Center, 'start', HorizontalAlign.Start))
            .translate({
              x: (MONITOR_SENSOR_RATE * this.xTranslate) + WidgetImageOffsetData.MONITOR_POSITION.x +
                (BOTH_Z_SENSOR_RATE * this.zTranslate),
              y: (-0.03 * this.xTranslate) + WidgetImageOffsetData.MONITOR_POSITION.y,
            })
        }
        // Code lines that fly out of the screen:
        WidgetLiveCardCodeComponent()

      }
      .height(this.formHeight)
      .width(this.formWidth)
      .borderRadius(this.formRadius)
      .backgroundColor(`rgba(43, 43, 43, 1.0)`)
      .margin({
        left: this.formLeft,
        bottom: this.formBottom,
      })
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      let localStorage: LocalStorage | undefined = this.getUIContext()?.getSharedLocalStorage();
      if (localStorage) {
        const formId: string = localStorage.get<string>('formId') as string;
        WidgetViewModel.cancelOverFlow(formId);
      } else {
        Logger.error(TAG, `Failed to get localStorage @LiveFormWidget.onClick.`);
      }
    })
  }
}
