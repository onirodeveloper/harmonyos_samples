/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { Logger } from '@ohos/common';
import type { BannerData } from '../model/BannerData';

const TAG: string = '[BannerSource]';

export class BannerSource implements IDataSource {
  public splashArray: BannerData[] = [];
  private listeners: DataChangeListener[] = [];

  public setDataArray(dataArray: BannerData[]): void {
    this.splashArray = dataArray;
  }

  public totalCount(): number {
    return this.splashArray.length;
  }

  public getData(index: number): BannerData {
    try {
      return this.splashArray[index];
    } catch (e) {
      Logger.error(TAG, `getData failed. ${e.message}`);
      return this.splashArray[0];
    }
  }

  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
}