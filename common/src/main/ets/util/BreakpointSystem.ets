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

import { display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { ProductSeriesEnum, StorageKey } from '../constant/CommonEnums';
import { BreakpointTypeEnum, GlobalInfoModel } from '../model/GlobalInfoModel';
import Logger from './Logger';

const TAG: string = '[BreakpointSystem]';

export interface BreakpointTypes<T> {
  xs?: T;
  sm: T;
  md: T;
  lg: T;
  xl?: T;
}

export class BreakpointType<T> {
  private xs: T;
  private sm: T;
  private md: T;
  private lg: T;
  private xl: T;

  public constructor(param: BreakpointTypes<T>) {
    this.xs = param.xs ?? param.sm;
    this.sm = param.sm;
    this.md = param.md;
    this.lg = param.lg;
    this.xl = param.xl ?? param.lg;
  }

  public getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakpointTypeEnum.XS) {
      return this.xs;
    }
    if (currentBreakpoint === BreakpointTypeEnum.SM) {
      return this.sm;
    }
    if (currentBreakpoint === BreakpointTypeEnum.MD) {
      return this.md;
    }
    if (currentBreakpoint === BreakpointTypeEnum.XL) {
      return this.xl;
    }
    return this.lg;
  }
}

export class BreakpointSystem {
  private static instance: BreakpointSystem;
  private currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;

  private constructor() {
  }

  public static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance;
  }

  public updateCurrentBreakpoint(breakpoint: BreakpointTypeEnum): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO) || new GlobalInfoModel();
      globalInfoModel.currentBreakpoint = this.currentBreakpoint;
      AppStorage.setOrCreate(StorageKey.GLOBAL_INFO, globalInfoModel);
    }
  }

  public onWindowSizeChange(window: window.Window): void {
    this.updateWidthBp(window);
  }

  public updateWidthBp(window: window.Window): void {
    try {
      const mainWindow: window.WindowProperties = window.getWindowProperties();
      const windowWidth: number = mainWindow.windowRect.width;
      const windowWidthVp = window.getUIContext().px2vp(windowWidth);
      const deviceType = deviceInfo.productSeries;
      if (deviceType === ProductSeriesEnum.HPR) {
        this.updateCurrentBreakpoint(BreakpointTypeEnum.XL);
        return;
      }
      let widthBp: BreakpointTypeEnum = BreakpointTypeEnum.MD;
      if (windowWidthVp < 320) {
        widthBp = BreakpointTypeEnum.XS;
      } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
        widthBp = BreakpointTypeEnum.SM;
      } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
        widthBp = BreakpointTypeEnum.MD;
      } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
        widthBp = BreakpointTypeEnum.LG;
      } else {
        widthBp = BreakpointTypeEnum.XL;
      }
      this.updateCurrentBreakpoint(widthBp);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to getWindowProperties. Cause: ${err.code}, ${err.message}`);
    }
  }
}