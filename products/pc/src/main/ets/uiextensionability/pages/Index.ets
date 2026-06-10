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
import { formInfo } from '@kit.FormKit';
import { sensor } from '@kit.SensorServiceKit';
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
  WidgetImageOffsetData
} from '@ohos/widgetcommon';
import { curves } from '@kit.ArkUI';

const TAG: string = '[LiveForm]';
const DOMAIN = 0x0000;
let storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct Index {
  imgScale: number = 1;
  sensor: sensor.Sensor | null = null;
  @State xTranslate: number = 0.0;
  @State yTranslate: number = 0.0;
  @State zTranslate: number = 0.0;
  @State oriHeight: number = 50;
  @State oriTranslate: TranslateOptions = { x: 0, y: 0 };
  @State oriAlpha: number = 1.0;
  @State textBGAlpha: number = 0.7;
  @State textAlpha: number = 1;
  @State fluffyHeight: number = 85;
  @State fluffyWidth: number = this.fluffyHeight * (16 / 9);
  @State fluffyIsReady: boolean = false;
  @State monitorHeight: number = 85;
  @State monitorWidth: number = this.monitorHeight;
  @State codeSize: number = 200;
  @State tx: TranslateOptions[] = [
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
  ];
  @State sx: ScaleOptions[] = [
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    { x: 0, y: 0 },
  ];
  @State fluffyIdx: number = 1;
  @State fluffyAnimateIntervalId: number | null = null;
  @State fluffyImage: string = fluffyList[this.fluffyIdx];
  @State codeList: Array<string> = codeList;
  @State delayParams: number[] = delayParams;
  private danmakuDirection: number = 8; // the number of clock in which direction code flies.
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
          /** // Plan-B: the Fluffy will move when the screen is moved:
          this.fluffyIdx += (theSensor.x + theSensor.y) % this.fluffyList.length; */
        }, { interval: GYROSCOPE_REFRESHING_INTERVAL });
      } catch (err) {
        let error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Failed to invoke on. Code: ${error.code}, message: ${error.message}`);
      }
    } else {
      Logger.info(TAG, `Failed to get gyroscope on this device.`);
    }
    this.setAnimeInterval(200);

  } // [End of aboutToAppear]

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

  // [Start overflow]
  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      RelativeContainer() {
        // [StartExclude overflow]
        Image($r('app.media.Fluffy_BG'))
          .height(`100%`)
          .borderRadius(this.formRadius)

        Image($r(`app.media.${this.fluffyImage}`))
          .objectFit(ImageFit.Fill)
          .height(`${this.fluffyHeight}%`)
          .width(`${this.fluffyWidth}%`)
          .alignRules(setAlignRules('center', VerticalAlign.Center, 'start', HorizontalAlign.Start))
          .translate({
            x: (FLUFFY_SENSOR_RATE * this.xTranslate) + WidgetImageOffsetData.FLUFFY_POSITION.x +
              (BOTH_Z_SENSOR_RATE * this.zTranslate),
            y: WidgetImageOffsetData.FLUFFY_POSITION.y
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
            .alignRules(setAlignRules('center', VerticalAlign.Center, 'start', HorizontalAlign.Start))
            .translate({
              x: (MONITOR_SENSOR_RATE * this.xTranslate) + WidgetImageOffsetData.MONITOR_POSITION.x +
                (BOTH_Z_SENSOR_RATE * this.zTranslate),
              y: (-0.03 * this.xTranslate) + WidgetImageOffsetData.MONITOR_POSITION.y,
            })
        }
        // Code lines that fly out of the screen:
        this.buildCodesAnimate();

        /**
         * If want to show Text Plate here, add:
         * this.buildTextPlate();
         * here.
         */
        // [EndExclude overflow]
      } // RelativeContainer
      .height(this.formHeight)
      .width(this.formWidth)
      .borderRadius(this.formRadius)
      .backgroundColor(`rgba(43, 43, 43, 1.0)`)
      .margin({
        left: this.formLeft,
        bottom: this.formBottom,
      })

      // [End of RelativeContainer]
    } // Stack
    .width('100%')
    .height('100%')

    // [End of Stack]
  } // [End of build]

  @Builder
  buildCodesAnimate() {
    ForEach(this.codeList, (imageName: string, idx: number) => {
      this.buildCodeImage(imageName, idx);
    })
  }

  @Builder
  buildCodeImage(imageResource: string, tsIdx: number) {
    Image($r(`app.media.${imageResource}`))
      .rotate({
        z: 1,
        angle: 0,
      })
      .width(`${this.codeSize}%`)
      .alignRules(setAlignRules('center', VerticalAlign.Center, 'middle', HorizontalAlign.Center))
      .translate(this.tx[tsIdx])
      .scale(this.sx[tsIdx])
      .opacity(0.65)
      .onAppear(() => {
        Logger.info(TAG, `CodeImage.onAppear ${tsIdx}, ${imageResource}`);
        this.getUIContext().animateTo({
          delay: this.delayParams[tsIdx],
          duration: 2650,
          playMode: PlayMode.Normal,
          iterations: -1,
          curve: curves.cubicBezierCurve(0.00, 0.50, 1.00, 1.00)
        }, () => {
          Logger.info(TAG, `CodeImage.afterAnimateTo.`);
          this.sx[tsIdx] = { x: 4.5, y: 4.5 };
          this.tx[tsIdx] = this.getTranslateParam();
          this.danmakuDirection = this.danmakuDirection + 7.62;
          /** A idea that can switch the angle randomly for 0~15 degree to the left or right.
           * this.danmakuDirection += Math.random() - 1;
           * */
        }) // [End of animateTo]
      })
  }

  private getTranslateParam(): TranslateOptions {
    // DanmakuDirection is the number of clock position.
    // replace this.DanmakuDirection with Math.random() can make code flies to random direction.
    const aParam: number = this.danmakuDirection / 12 * 2 * Math.PI;
    const ret: TranslateOptions = {
      x: 700 * Math.sin(aParam) + 30,
      y: 200 * Math.cos(aParam)
    };
    return ret;
  }

  @Builder
  buildTextPlate() {
    Row() {
      Column() {
        Text($r('app.string.widget_hmos_coding_title'))
          .minFontSize(8)
          .maxFontSize(12)
          .fontWeight(FontWeight.Medium)
          .margin({
            bottom: 2
          })
          .fontColor(`rgba(0, 0, 0, ${this.textAlpha})`)
        Text($r('app.string.widget_hmos_coding_text'))
          .minFontSize(6)
          .maxFontSize(10)
          .fontColor(`rgba(100, 100, 100, ${this.textAlpha})`)
      }
      .alignItems(HorizontalAlign.Start)

      // [End of Column]
    } // Row
    .alignRules(setAlignRules('bottom', VerticalAlign.Bottom, 'middle', HorizontalAlign.Center))
    .backgroundColor(`rgba(255, 255, 255, ${this.textBGAlpha})`)
    .borderRadius(12)
    .padding(8)
    .id('row')
    .margin(10)
    .onAppear(() => {
      this.getUIContext().keyframeAnimateTo(
        {
          delay: 0,
          iterations: 1,
          expectedFrameRateRange: {
            min: 10,
            max: 120,
            expected: 60,
          }
        },
        [
          {
            duration: 1000,
            curve: Curve.EaseInOut,
            event: () => {
              this.textAlpha = 0;
              this.textBGAlpha = 0;
            }
          },
          {
            duration: 3000,
            curve: Curve.Linear,
            event: () => {
              this.textAlpha = 0;
              this.textBGAlpha = 0;
            }
          },
          {
            duration: 500,
            curve: Curve.EaseInOut,
            event: () => {
              this.textAlpha = 1;
              this.textBGAlpha = 0.7;
            }
          }
        ]) // [End of keyframeAnimateTo]
    }) // [End of onAppear]
  } // [End of buildTextPlate]

  // [End overflow]
}

type AlignParam = Record<string, string | VerticalAlign | HorizontalAlign>;

function setAlignRules(verticalName: string, verticalAlign: VerticalAlign,
  horizontalName: string, horizontalAlign: HorizontalAlign): Record<string, AlignParam> {

  let alignRule: Record<string, AlignParam> = {};
  alignRule[verticalName] = { 'anchor': '__container__', 'align': verticalAlign };
  alignRule[horizontalName] = { 'anchor': '__container__', 'align': horizontalAlign };
  return alignRule;
};