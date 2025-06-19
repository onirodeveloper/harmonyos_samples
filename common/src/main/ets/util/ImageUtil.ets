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

import type { BusinessError } from '@kit.BasicServicesKit';
import { PreferenceManager } from '../storagemanager/PreferenceManager';
import { ColorUtil } from './ColorUtil';
import Logger from './Logger';
import { ResourceUtil } from './ResourceUtil';

const BANNER_IMAGE_COLOR = 'banner_image_color';
const TAG = '[ImageUtil]';

export class ImageUtil {
  public static getColorFromImgUrl(imgUrl: string, isDeepColor?: boolean): Promise<number[]> {
    return new Promise((resolve: (value: number[]) => void, reject: (reason?: Object) => void) => {
      ImageUtil.getColorDataByPreference(imgUrl).then((data: number[]) => {
        resolve(data);
      }).catch(() => {
        ImageUtil.getColorByPath(imgUrl, isDeepColor).then((colorData: number[]) => {
          resolve(colorData);
        }).catch((err: BusinessError) => {
          Logger.error(TAG, `Failed to Save ImageData. error ${err.code}  ${err.message}`);
          reject();
        });
      });
    });
  }

  private static getColorByPath(imageUrl: string, isDeepColor?: boolean): Promise<number[]> {
    return new Promise((resolve: (value: number[]) => void, reject: (reason?: Object) => void) => {
      ResourceUtil.getColorDataByPath(imageUrl).then((colors: number[]) => {
        let colorArr: number[] = colors;
        if (isDeepColor) {
          colorArr = ColorUtil.getDeepenImmersionColor(colors[0], colors[1], colors[2]);
        }
        ImageUtil.setColorDataToPreference(imageUrl, colorArr);
        resolve(colorArr);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to getColorDataByPath. error ${err.code}  ${err.message}`);
        reject();
      })
    });
  }

  private static getColorDataByPreference(imgUrl: string): Promise<number[]> {
    return new Promise((resolve: (value: number[]) => void, reject: (reason?: Object) => void) => {
      PreferenceManager.getInstance()
        .getValue<Record<string, number[]>>(BANNER_IMAGE_COLOR)
        .then((resp) => {
          if (!resp) {
            reject('There is no data in the Preference');
          }
          resp = (resp as Record<string, number[]>);
          const ret = resp[imgUrl];
          if (!ret) {
            reject('There is no data in the Preference');
          }
          resolve(ret);
        });
    });
  }

  private static setColorDataToPreference(imgUrl: string, data: number[]): Promise<void> {
    return new Promise((resolve: () => void) => {
      PreferenceManager.getInstance().hasValue(BANNER_IMAGE_COLOR)
        .then((result) => {
          if (result) {
            PreferenceManager.getInstance()
              .getValue<Record<string, number[]>>(BANNER_IMAGE_COLOR)
              .then((resp) => {
                resp = (resp as Record<string, number[]>);
                resp[imgUrl] = data;
                PreferenceManager.getInstance().setValue(BANNER_IMAGE_COLOR, resp);
                resolve();
              })
          } else {
            const record: Record<string, number[]> = {};
            record[imgUrl] = data;
            PreferenceManager.getInstance().setValue(BANNER_IMAGE_COLOR, record);
          }
        });
    });
  }
}