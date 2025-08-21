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
import { ProductSeriesEnum, StorageKey } from '../constant/CommonEnums';
import { GlobalInfoModel } from '../model/GlobalInfoModel';
import { BreakpointSystem } from './BreakpointSystem';
import Logger from './Logger';

const TAG: string = '[WindowUtil]';

export class WindowUtil {
  private static windowClass?: window.Window;
  private static uiContext: UIContext;

  public static initialize(windowStage: window.WindowStage) {
    try {
      WindowUtil.windowClass = windowStage.getMainWindowSync();
      const uiContext: UIContext = WindowUtil.windowClass.getUIContext();
      WindowUtil.uiContext = uiContext;
      AppStorage.setOrCreate<UIContext>(StorageKey.UI_CONTEXT, uiContext);
      WindowUtil.registerBreakpoint(WindowUtil.windowClass);
      WindowUtil.requestFullScreen();
      // Hide PC/2in1 title bar.
      WindowUtil.hideTitleBar();
    } catch (err) {
      Logger.error(TAG, `WindowUtil initialize failed. Cause: ${err.code} ${err.message}`);
    }
  }

  public static updateStatusBarColor(isDark: boolean): void {
    try {
      WindowUtil.windowClass?.setWindowSystemBarProperties({
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
  }

  private static hideTitleBar() {
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        WindowUtil.windowClass?.setWindowDecorVisible(false);
        WindowUtil.windowClass?.setWindowDecorHeight(CommonConstants.NAVIGATION_HEIGHT);
      } else {
        Logger.error(TAG, `setWindowDecorVisible invalid`);
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to set the visibility of window decor. Cause: ${err.code}, ${err.message}`);
    }
  }

  private static requestFullScreen(): void {
    // Realize the immersive effect.
    try {
      if (deviceInfo.productSeries === ProductSeriesEnum.HPR) {
        WindowUtil.resetWindowSize();
      }
      const promise: Promise<void> | undefined = WindowUtil.windowClass?.setWindowLayoutFullScreen(true);
      promise?.then(() => {
        Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to set the window layout to full-screen mode. Cause: ${err.code}, ${err.message}`);
      });
      WindowUtil.getDeviceSize();
    } catch {
      Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
    }
  }

  private static resetWindowSize(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        const windowSize: display.Display = display.getDefaultDisplaySync();
        const appWidth: number = windowSize.width * 9 / 10;
        const appHeight: number = windowSize.height * 7 / 8;
        const windowLimits: window.WindowLimits = {
          maxWidth: appWidth,
          maxHeight: appHeight,
          minWidth: appWidth,
          minHeight: appHeight,
        };
        WindowUtil.windowClass?.setWindowLimits(windowLimits);
        WindowUtil.windowClass?.moveWindowToAsync(windowSize.width / 20, windowSize.height / 16);
      } catch (err) {
        Logger.error(TAG, `Failed to getDefaultDisplaySync.`);
      }
    }
  }

  private static getDeviceSize(): void {
    // Get device height.
    try {
      const properties = WindowUtil.windowClass?.getWindowProperties();
      const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) || new GlobalInfoModel();
      if (properties?.windowRect) {
        globalInfoModel.deviceHeight = WindowUtil.uiContext.px2vp(properties.windowRect.height);
        globalInfoModel.deviceWidth = WindowUtil.uiContext.px2vp(properties.windowRect.width);
      }
      if (canIUse('SystemCapability.Window.SessionManager')) {
        const decorHeight: number = WindowUtil.windowClass?.getWindowDecorHeight() || 0;
        globalInfoModel.decorHeight = decorHeight;
      }
      AppStorage.setOrCreate(StorageKey.GLOBAL_INFO, globalInfoModel);
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(TAG, `Get and setDeviceSize failed. code: ${error.code}, message: ${error.message}`);
    }
  }

  public static setMainWindowOrientation(orientation: window.Orientation, onSuccess?: () => void): void {
    try {
      // Setting window preferred orientation.
      WindowUtil.windowClass?.setPreferredOrientation(orientation, (err: BusinessError) => {
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
  }

  public static setMissionContinueActive(context: common.UIAbilityContext, active: boolean) {
    const activeState = active ? AbilityConstant.ContinueState.ACTIVE : AbilityConstant.ContinueState.INACTIVE;
    context.setMissionContinueState(activeState).then(() => {
      Logger.info(TAG, 'setMissionContinueState success');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `setMissionContinueState failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  public static enableFloatWindowRotate(): void {
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        WindowUtil.windowClass?.enableLandscapeMultiWindow();
      } else {
        Logger.error(TAG, `enableLandscapeMultiWindow invalid`);
      }
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(TAG, `enableLandscapeMultiWindow failed. code: ${error.code}, message: ${error.message}`);
    }
  }

  public static disableFloatWindowRotate(): void {
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        WindowUtil.windowClass?.disableLandscapeMultiWindow();
      } else {
        Logger.error(TAG, `disableLandscapeMultiWindow invalid`);
      }
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(TAG, `disableLandscapeMultiWindow failed. code: ${error.code}, message: ${error.message}`);
    }
  }

  private static registerBreakpoint(windowClass: window.Window) {
    BreakpointSystem.getInstance().updateWidthBp(windowClass);
    try {
      const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) || new GlobalInfoModel();
      const systemAvoidArea: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      globalInfoModel.statusBarHeight = WindowUtil.uiContext.px2vp(systemAvoidArea.topRect.height);
      const bottomArea: window.AvoidArea =
        windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      globalInfoModel.naviIndicatorHeight = WindowUtil.uiContext.px2vp(bottomArea.bottomRect.height);
      AppStorage.setOrCreate(StorageKey.GLOBAL_INFO, globalInfoModel);
      windowClass.on('windowSizeChange', () => WindowUtil.onWindowSizeChange(windowClass));
      windowClass.on('avoidAreaChange', (avoidAreaOption) => {
        if (avoidAreaOption.type === window.AvoidAreaType.TYPE_SYSTEM ||
          avoidAreaOption.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          WindowUtil.setAvoidArea(avoidAreaOption.type, avoidAreaOption.area);
        }
      });
    } catch (err) {
      Logger.error(TAG, `getWindowAvoidArea failed. error message: ${err.message}`);
    }
  }

  // Get status bar height and indicator height.
  public static setAvoidArea(type: window.AvoidAreaType, area: window.AvoidArea) {
    const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) || new GlobalInfoModel();
    if (type === window.AvoidAreaType.TYPE_SYSTEM) {
      globalInfoModel.statusBarHeight = WindowUtil.uiContext.px2vp(area.topRect.height);
    } else {
      globalInfoModel.naviIndicatorHeight = WindowUtil.uiContext.px2vp(area.bottomRect.height);
    }
    AppStorage.setOrCreate(StorageKey.GLOBAL_INFO, globalInfoModel);
  }

  public static onWindowSizeChange(window: window.Window) {
    WindowUtil.getDeviceSize();
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