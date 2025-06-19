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

import type { common } from '@kit.AbilityKit';
import { AbilityConstant } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constant/CommonConstants';
import { ProductSeriesEnum } from '../constant/CommonEnums';
import { GlobalInfoModel } from '../model/GlobalInfoModel';
import { BreakpointSystem } from './BreakpointSystem';
import Logger from './Logger';

const TAG: string = '[WindowUtil]';

export class WindowUtil {
  public static updateStatusBarColor(context: common.BaseContext, isDark: boolean): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      try {
        windowClass.setWindowSystemBarProperties({
          statusBarContentColor: isDark ? StatusBarColorType.WHITE : StatusBarColorType.BLACK
        }).then(() => {
          Logger.info(TAG, 'Succeeded in setting the system bar properties.');
        }).catch((err: BusinessError) => {
          Logger.error(TAG, `Failed to set the system bar properties. Cause: ${err.code} ${err.message}`);
        });
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to set the system bar properties. Cause: ${err.code}, ${err.message}`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `GetLastWindow failed. code: ${error.code}, message: ${error.message}`);
    });
  }

  public static hideTitleBar(windowStage: window.WindowStage) {
    windowStage.getMainWindow().then((data: window.Window) => {
      try {
        if (canIUse('SystemCapability.Window.SessionManager')) {
          data.setWindowDecorVisible(false);
          data.setWindowDecorHeight(CommonConstants.NAVIGATION_HEIGHT);
        } else {
          Logger.error(TAG, `setWindowDecorVisible invalid`);
        }
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to set the visibility of window decor. Cause: ${err.code}, ${err.message}`);
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to obtain the main window. Cause: ${err.code}, ${err.message}`);
    })
  }

  public static requestFullScreen(windowStage: window.WindowStage, context: Context): void {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, `Failed to obtain the main window. Cause: ${err.code}, ${err.message}`);
        return;
      }
      Logger.debug(TAG, `Succeeded in obtaining the main window. Data: ${JSON.stringify(data)}`);
      const windowClass: window.Window = data;
      // Realize the immersive effect.
      try {
        if (deviceInfo.productSeries === ProductSeriesEnum.HPR) {
          WindowUtil.resetWindowSize(windowClass);
        }
        const promise: Promise<void> = windowClass.setWindowLayoutFullScreen(true);
        promise.then(() => {
          Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
        }).catch((err: BusinessError) => {
          Logger.error(TAG,
            `Failed to set the window layout to full-screen mode. Cause: ${err.code}, ${err.message}`);
        });
        WindowUtil.getDeviceSize(context);
      } catch {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
      }
    });
  }

  private static resetWindowSize(windowClass: window.Window): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      const windowSize: display.Display = display.getDefaultDisplaySync();
      const appWidth: number = windowSize.width * 9 / 10;
      const appHeight: number = windowSize.height * 7 / 8;
      const windowLimits: window.WindowLimits = {
        maxWidth: appWidth,
        maxHeight: appHeight,
        minWidth: appWidth,
        minHeight: appHeight,
      }
      windowClass.setWindowLimits(windowLimits);
      windowClass.moveWindowToAsync(windowSize.width / 20, windowSize.height / 16);
    }
  }

  private static getDeviceSize(context: Context): void {
    // Get device height.
    window.getLastWindow(context).then((data: window.Window) => {
      try {
        const properties = data.getWindowProperties();
        const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel') || new GlobalInfoModel();
        globalInfoModel.deviceHeight = px2vp(properties.windowRect.height);
        globalInfoModel.deviceWidth = px2vp(properties.windowRect.width);
        if (canIUse('SystemCapability.Window.SessionManager')) {
          const decorHeight: number = data?.getWindowDecorHeight();
          globalInfoModel.decorHeight = decorHeight;
        }
        AppStorage.setOrCreate('GlobalInfoModel', globalInfoModel);
      } catch (err) {
        const error = err as BusinessError;
        Logger.error(TAG, `Get and setDeviceSize failed. code: ${error.code}, message: ${error.message}`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `GetLastWindow failed. code: ${error.code}, message: ${error.message}`);
    });
  }

  public static setMainWindowOrientation(context: Context, orientation: window.Orientation,
    onSuccess?: () => void): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(TAG, `MainWindowClass is undefined.`);
        return;
      }
      try {
        // Setting window preferred orientation.
        windowClass.setPreferredOrientation(orientation, (err: BusinessError) => {
          const errCode = err.code;
          if (errCode) {
            Logger.error(TAG, `Failed to set window orientation. Cause code: ${err.code}, message: ${err.message}`);
            return;
          }
          onSuccess?.();
        });
      } catch (err) {
        const error = err as BusinessError;
        Logger.error(TAG, `SetPreferredOrientation failed. code: ${error.code}, message: ${error.message}`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `GetLastWindow failed. code: ${error.code}, message: ${error.message}`);
    });
  }

  public static setMissionContinueActive(context: common.UIAbilityContext, active: boolean) {
    const activeState = active ? AbilityConstant.ContinueState.ACTIVE : AbilityConstant.ContinueState.INACTIVE;
    context.setMissionContinueState(activeState).then(() => {
      Logger.info(TAG, 'setMissionContinueState success');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `setMissionContinueState failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  public static enableFloatWindowRotate(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(TAG, `MainWindowClass is undefined`);
        return;
      }
      try {
        if (canIUse('SystemCapability.Window.SessionManager')) {
          windowClass.enableLandscapeMultiWindow();
        } else {
          Logger.error(TAG, `enableLandscapeMultiWindow invalid`);
        }
      } catch (err) {
        const error = err as BusinessError;
        Logger.error(TAG, `enableLandscapeMultiWindow failed. code: ${error.code}, message: ${error.message}`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `GetLastWindow failed. code: ${error.code}, message: ${error.message}`);
    });
  }

  public static disableFloatWindowRotate(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(TAG, `MainWindowClass is undefined`);
        return;
      }
      try {
        if (canIUse('SystemCapability.Window.SessionManager')) {
          windowClass.disableLandscapeMultiWindow();
        } else {
          Logger.error(TAG, `disableLandscapeMultiWindow invalid`);
        }
      } catch (err) {
        const error = err as BusinessError;
        Logger.error(TAG, `disableLandscapeMultiWindow failed. code: ${error.code}, message: ${error.message}`);
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `GetLastWindow failed. code: ${error.code}, message: ${error.message}`);
    });
    ;
  }

  public static registerBreakPoint(windowStage: window.WindowStage) {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, `Failed to get main window: ${err.message}`);
        return;
      }
      try {
        BreakpointSystem.getInstance().updateWidthBp(data);
        const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel') || new GlobalInfoModel();
        const systemAvoidArea: window.AvoidArea = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        globalInfoModel.statusBarHeight = px2vp(systemAvoidArea.topRect.height);
        const bottomArea: window.AvoidArea = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        globalInfoModel.naviIndicatorHeight = px2vp(bottomArea.bottomRect.height);
        AppStorage.setOrCreate('GlobalInfoModel', globalInfoModel);
        data.on('windowSizeChange', () => WindowUtil.onWindowSizeChange(data));
        data.on('avoidAreaChange', (avoidAreaOption) => {
          if (avoidAreaOption.type === window.AvoidAreaType.TYPE_SYSTEM ||
            avoidAreaOption.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            WindowUtil.setAvoidArea(avoidAreaOption.type, avoidAreaOption.area);
          }
        });
      } catch (e) {
        const error = e as BusinessError;
        Logger.error(TAG, `getWindowAvoidArea failed. code: ${error.code}, message: ${error.message}`);
      }
    });
  }

  // Get status bar height and indicator height.
  public static setAvoidArea(type: window.AvoidAreaType, area: window.AvoidArea) {
    const globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel') || new GlobalInfoModel();
    if (type === window.AvoidAreaType.TYPE_SYSTEM) {
      globalInfoModel.statusBarHeight = px2vp(area.topRect.height);
    } else {
      globalInfoModel.naviIndicatorHeight = px2vp(area.bottomRect.height);
    }
    AppStorage.setOrCreate('GlobalInfoModel', globalInfoModel);
  }

  public static onWindowSizeChange(window: window.Window) {
    WindowUtil.getDeviceSize(getContext());
    BreakpointSystem.getInstance().onWindowSizeChange(window);
  }
}

export enum StatusBarColorType {
  WHITE = '#ffffff',
  BLACK = '#E5000000',
}

export enum ScreenOrientation {
  PORTRAIT = 'portrait',
  LANDSCAPE = 'landscape',
}