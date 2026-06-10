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

import { matrix4, window } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { StorageKey } from '@ohos/common';

@Observed
export class ImageModel {
  // Copy function of Matrix
  public matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  // The current scale
  public curScale: number = 1;
  // The current offset X
  public curOffsetX: number = 0;
  // The current offset is Y
  public curOffsetY: number = 0;
  // Record the last zoom
  public lastScale: number = 1;
  // Record the offset of the last X-axis
  public lastOffsetX: number = 0;
  // Records the last Y-axis offset
  public lastOffsetY: number = 0;
  // Minimum image zoom
  public minScale: number = 0.5;
  // Maximum zoom of the image
  public maxScale: number = 1;
  // Default zoom
  public defaultScaleValue: number = 1;
  // Maximum deviation of the X-axis
  public maxOffsetX: number = 999;
  // Minimum deviation of the X-axis
  public minOffsetX: number = -999;
  // Maximum deviation of the Y-axis
  public maxOffsetY: number = 999;
  // Minimum deviation of Y-axis
  public minOffsetY: number = -999;
  public centerX: number = 0.5;
  public centerY: number = 0.5;
  public center: number[] = [0.5, 0.5];
  public componentHeight: number = 0;
  public componentWidth: number = 0;
  // Picture Width
  public imageWidth: number = 100;
  // Picture Height
  public imageHeight: number = 100;
  // Whether to allow swiper components to slide
  public isDisableSwipe: boolean = false;
  public isArriveBoundary: boolean = false;

  constructor(
    matrix: matrix4.Matrix4Transit = matrix4.identity().copy(),
    curScale: number = 1,
    curOffsetX: number = 0,
    curOffsetY: number = 0,
    lastScale: number = 1,
    lastOffsetX: number = 0,
    lastOffsetY: number = 0,
    minScale: number = 0.5,
    maxScale: number = 1,
    defaultScaleValue: number = 1,
    maxOffsetX: number = 999,
    minOffsetX: number = -999,
    maxOffsetY: number = 999,
    minOffsetY: number = -999,
    centerX: number = 0.5,
    centerY: number = 0.5,
    center: [number, number] = [0, 0],
    componentHeight: number = 0,
    componentWidth: number = 0,
    imageWidth: number = 100,
    imageHeight: number = 100,
    isDisableSwipe: boolean = false,
    isArriveBoundary: boolean = false
  ) {
    this.matrix = matrix;
    this.curScale = curScale;
    this.curOffsetX = curOffsetX;
    this.curOffsetY = curOffsetY;
    this.lastScale = lastScale;
    this.lastOffsetX = lastOffsetX;
    this.lastOffsetY = lastOffsetY;
    this.minScale = minScale;
    this.maxScale = maxScale;
    this.maxScale = maxScale;
    this.defaultScaleValue = defaultScaleValue;
    this.maxOffsetX = maxOffsetX;
    this.minOffsetX = minOffsetX;
    this.maxOffsetY = maxOffsetY;
    this.minOffsetY = minOffsetY;
    this.centerX = centerX;
    this.centerY = centerY;
    this.center = center;
    this.componentHeight = componentHeight;
    this.componentWidth = componentWidth;
    this.imageWidth = imageWidth;
    this.imageHeight = imageHeight;
    this.isDisableSwipe = isDisableSwipe;
    this.isArriveBoundary = isArriveBoundary;
  }

  // Pan gestures callback during movement.
  gestureEnd(): void {
    this.lastScale = this.curScale;
    this.lastOffsetX = this.curOffsetX;
    this.lastOffsetY = this.curOffsetY;
  }

  // When switching images, reset the previous image.
  imageReset(): void {
    setTimeout(() => {
      this.matrix = matrix4.identity().scale({
        x: this.defaultScaleValue,
      }).copy();
      this.lastScale = this.defaultScaleValue;
      this.offsetReset();
    }, 200);
    AppStorage.setOrCreate(StorageKey.IS_IMAGE_DEFAULT_SIZE, true);
  }

  // Offset reset.
  offsetReset(): void {
    this.curOffsetX = 0;
    this.curOffsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
  }

  // Get window size.
  windowSize(deviceWidth?: number, deviceHeight?: number): void {
    this.componentWidth = deviceWidth as number;
    this.componentHeight = deviceHeight as number;
  }

  pictureScaling(scale: number): void {
    this.matrix = matrix4.identity().scale({
      x: scale,
      y: scale
    }).copy();
  }

  // Calculate the range of the picture boundary.
  evaluateOffsetRange(): void {
    // Calculate the actual display size of the scaled image.
    let scaledImageWidth = this.imageWidth * this.curScale;
    let scaledImageHeight = this.imageHeight * this.curScale;

    // Calculation of X-axis boundaries
    if (scaledImageWidth > this.componentWidth) {
      // If the width of the picture exceeds the width of the screen, you can move it left and right.
      let maxXOffset = (scaledImageWidth - this.componentWidth) / 2;
      this.maxOffsetX = maxXOffset;
      this.minOffsetX = -maxXOffset;
    } else {
      // The width of the image does not exceed the width of the screen.
      // It should be centered and no X-axis offset is allowed.
      this.maxOffsetX = 0;
      this.minOffsetX = 0;
    }

    // Y-axis boundary calculation
    if (scaledImageHeight > this.componentHeight) {
      // If the image height exceeds the screen height, it can be scrolled up and down.
      let maxYOffset = (scaledImageHeight - this.componentHeight) / 2;
      this.maxOffsetY = maxYOffset;
      this.minOffsetY = -maxYOffset;
    } else {
      // The height of the image does not exceed the height of the screen.
      // It should be centered and no Y-axis offset is allowed.
      this.maxOffsetY = 0;
      this.minOffsetY = 0;
    }
  }

  // Calculates the percentage position of the current zoom center relative to the picture
  evaluateCenter(centerX: number, centerY: number): [number, number] {
    let imgDisplayWidth = this.imageWidth * this.lastScale;
    let imgDisplayHeight = this.imageHeight * this.lastScale;
    let imgX = (this.componentWidth - imgDisplayWidth) / 2 + this.lastOffsetX;
    let imgY = (this.componentHeight - imgDisplayHeight) / 2 + this.lastOffsetY;
    let cX = Math.max((centerX - imgX) / imgDisplayWidth, 0);
    let cY = Math.max((centerY - imgY) / imgDisplayHeight, 0);
    return [cX, cY];
  }

  // Calculate the maximum zoom value of the picture.
  calcFitScaleRatio(imageSize: image.Size, windowSize: window.Size): number {
    let ratio: number = 1.0;
    if (windowSize.width > imageSize.width) {
      ratio = windowSize.width / imageSize.width;
    } else {
      ratio = windowSize.height / imageSize.height;
    }
    return ratio + 1;
  }

  // Pan gestures callback during movement.
  panGestureUpdate(event: GestureEvent): boolean {
    this.onScale(event.scale, event.offsetX, event.offsetY);
    this.pictureBoundaryRestriction();
    return this.isDisableSwipe;
  }

  // Pinch gesture recognition successful callback.
  pinchGestureStart(event: GestureEvent): void {
    this.center = this.evaluateCenter(event.pinchCenterX, event.pinchCenterY);
    this.centerX = 1 - this.center[0];
    this.centerY = 1 - this.center[1];
  }

  // Picture Boundary Restriction
  pictureBoundaryRestriction(): void {
    // X-axis boundary restriction
    if (this.curOffsetX > this.maxOffsetX) {
      this.curOffsetX = this.maxOffsetX;
      this.isDisableSwipe = false;
      this.isArriveBoundary = true;
    } else if (this.curOffsetX < this.minOffsetX) {
      this.curOffsetX = this.minOffsetX;
      this.isDisableSwipe = false;
      this.isArriveBoundary = true;
    }
    // Y-axis boundary limit
    if (this.curOffsetY > this.maxOffsetY) {
      this.curOffsetY = this.maxOffsetY;
    } else if (this.curOffsetY < this.minOffsetY) {
      this.curOffsetY = this.minOffsetY;
    }
    // When the image cannot fill the entire screen, force it to be centered.
    let scaledImageWidth = this.imageWidth * this.curScale;
    let scaledImageHeight = this.imageHeight * this.curScale;
    if (scaledImageWidth <= this.componentWidth) {
      // The width of the image does not exceed the screen. Force the X-axis to be centered.
      this.curOffsetX = 0;
    }
    if (scaledImageHeight <= this.componentHeight) {
      // The height of the image does not exceed the screen, and the Y-axis is forced to be centered.
      this.curOffsetY = 0;
    }
  }

  // Pinch gestures callback during a move.
  pinchGestureUpdate(event: GestureEvent): boolean {
    this.onScale(event.scale, event.offsetX, event.offsetY);
    this.pictureScaling(this.curScale);
    if (this.curScale > this.defaultScaleValue) {
      this.isDisableSwipe = true;
    }
    this.pictureBoundaryRestriction();
    return this.isDisableSwipe;
  }

  // The Pinch gesture is recognized successfully, and the callback is triggered when the finger is lifted.
  pinchGestureEnd(): void {
    runWithAnimation(() => {
      // When the scale is less than 1
      if (this.curScale <= this.defaultScaleValue) {
        this.pictureScaling(this.defaultScaleValue);
        this.imageReset();
      } else if (this.curScale >= this.maxScale) {
        this.curScale -= 0.1;
        this.pictureScaling(this.curScale);
      }
      this.gestureEnd();
    });
  }

  // Tap gesture recognition callback succeeded.
  doubleTapGesture(event: GestureEvent): boolean {
    let curRatio: number = 1;
    this.center = this.evaluateCenter(event.fingerList[0].displayX, event.fingerList[0].displayY);
    this.centerX = 1 - this.center[0];
    this.centerY = 1 - this.center[1];
    // When the last scale is greater than 1, the default scale is restored
    if (this.lastScale > this.defaultScaleValue) {
      runWithAnimation(() => {
        this.pictureScaling(this.defaultScaleValue);
        this.offsetReset();
      });
      curRatio = this.defaultScaleValue;
      this.isDisableSwipe = false;
      AppStorage.setOrCreate(StorageKey.IS_IMAGE_DEFAULT_SIZE, true);
    } else {
      runWithAnimation(() => {
        this.onScale(event.scale, event.offsetX, event.offsetY);
        this.pictureScaling(this.maxScale);
        this.offsetReset();
      });
      curRatio = this.maxScale;
      this.isDisableSwipe = true;
      AppStorage.setOrCreate(StorageKey.IS_IMAGE_DEFAULT_SIZE, false);
    }
    this.lastScale = curRatio;
    return this.isDisableSwipe;
  }

  // Calculates the offset X and offset Y of the current picture and the scaling value of the current picture.
  onScale(scale: number, offX: number, offY: number): void {
    if (this.lastScale * scale > this.maxScale) {
      this.curScale = this.maxScale;
    } else if (this.lastScale * scale < this.minScale) {
      this.curScale = this.minScale;
    } else {
      this.curScale = this.lastScale * scale;
    }
    if (this.lastScale * scale === this.maxScale) {
      this.curScale -= 0.001;
    }
    this.evaluateOffsetRange();
    if (this.curScale < this.maxScale) {
      this.curOffsetY =
        (this.lastOffsetY + offY) + (0.5 - this.centerY) * this.imageHeight * (1 - scale) * this.lastScale;
      this.curOffsetX =
        (this.lastOffsetX + offX) + (0.5 - this.centerX) * this.imageWidth * (1 - scale) * this.lastScale;
    }
    // When the image is in the process of moving, it has not reached the boundary point.
    this.isArriveBoundary = false;
    // If the image has not reached the boundary, do not allow the image to be switched.
    if (!this.isArriveBoundary) {
      this.isDisableSwipe = true;
    }
  }
}

function runWithAnimation(
  fn: Function,
  duration: number = 300, // Scale the duration of the animation
  curve: Curve = Curve.Smooth): void {
  const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
  uiContext!.animateTo({ duration: duration, curve: curve }, () => {
    fn();
  });
}