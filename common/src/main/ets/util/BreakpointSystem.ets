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

  public getValue(currentBreakpoint: WidthBreakpoint): T {
    if (currentBreakpoint === WidthBreakpoint.WIDTH_XS) {
      return this.xs;
    }
    if (currentBreakpoint === WidthBreakpoint.WIDTH_SM) {
      return this.sm;
    }
    if (currentBreakpoint === WidthBreakpoint.WIDTH_MD) {
      return this.md;
    }
    if (currentBreakpoint === WidthBreakpoint.WIDTH_XL) {
      return this.xl;
    }
    return this.lg;
  }
}