/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { effectKit } from '@kit.ArkGraphics2D';
import { JSON, util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { StorageKey } from '../constant/CommonEnums';
import Logger from './Logger';

const TAG: string = '[ResourceUtil]';

export class ResourceUtil {
  /**
   * Obtains the character string corresponding to the specified resource ID.
   *
   * @param resource resource.
   */
  public static getResourceString(context: Context, resource: Resource): string {
    if (ResourceUtil.isEmptyObj(resource)) {
      Logger.error(TAG, '[getResourceString] resource is empty.');
      return '';
    }
    let resourceString: string = '';
    try {
      resourceString = context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `[getResourceString]getStringSync failed, error: ${err.code}, ${err.message}.`);
    }
    return resourceString;
  }

  /**
   * Check whether the object is empty.
   *
   * @param obj Objects to be checked.
   * @returns Return true if the object is empty or has no properties; Otherwise return false.
   */
  private static isEmptyObj(obj: Object): boolean {
    if (obj === null || typeof obj !== 'object') {
      return true;
    }
    return Object.keys(obj).length === 0;
  }

  /**
   * Get content from the raw file resource "hmos_web_config.json" by key.
   * @param context The base context of an ability or an application.
   * @param key The Json key value.
   * @returns Return the value of the key.
   */
  public static getRawFileStringByKey(context: Context, key: ConfigMapKey): string {
    const configStr: string | undefined = AppStorage.get(key);
    if (configStr) {
      return configStr;
    }
    try {
      const result: Uint8Array = context.resourceManager.getRawFileContentSync('hmos_web_config.json');
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const content: string = textDecoder.decodeToString(result, { stream: false });
      const jsonContent: ConfigMapData = JSON.parse(content) as ConfigMapData;
      if (JSON.has(jsonContent, key)) {
        const linkUrl: string = ResourceUtil.getDataByKey(jsonContent, key);
        AppStorage.setOrCreate(key, linkUrl);
        return linkUrl;
      }
      Logger.error(TAG, `GetRawFileContent failed, cause: no ${key} value is configured.`);
      return '';
    } catch (error) {
      Logger.error(TAG, `GetRawFileContent failed, error code: ${error.code}, message: ${error.message}.`);
      return '';
    }
  }

  private static getDataByKey(content: ConfigMapData, key: ConfigMapKey): string {
    if (key === ConfigMapKey.GALLERY_URL) {
      return content.galleryUrl;
    } else if (key === ConfigMapKey.MIIT_URL) {
      return content.miitUrl;
    } else if (key === ConfigMapKey.WHITELIST) {
      return content.whitelist;
    }
    return '';
  }

  public static getColorDataByPath(mediaUrl: string): Promise<number[]> {
    const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
    const context: Context = uiContext.getHostContext() as Context;
    return new Promise((resolve: (value: number[]) => void, reject: (reason?: Object) => void) => {
      context.resourceManager.getRawFileContent(mediaUrl)
        .then((unit8Array: Uint8Array) => {
          let imageSource: image.ImageSource | undefined = undefined;
          let pixelMap: image.PixelMap | undefined = undefined;
          try {
            imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
            pixelMap = imageSource.createPixelMapSync({
              desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
            });
            effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
              if (err) {
                Logger.error(TAG, 'Failed to create color picker');
                reject(err);
              } else {
                const color = colorPicker.getLargestProportionColor();
                resolve([color.red, color.green, color.blue]);
              }
            });
          } catch (error) {
            Logger.error(TAG, `GetRawFileContent failed, error code: ${error.code}, message: ${error.message}.`);
            reject(error);
          } finally {
            imageSource?.release();
            pixelMap?.release();
          }
        }).catch((error: BusinessError) => {
        Logger.error(TAG, `[getPixelMapByPath] failed, error code: ${error.code}, message: ${error.message}.`);
        reject(error);
      });
    });
  }
}

export class ConfigMapData {
  public galleryUrl: string = '';
  public miitUrl: string = '';
  public whitelist: string = '';
}

export enum ConfigMapKey {
  GALLERY_URL = 'galleryUrl',
  MIIT_URL = 'miitUrl',
  WHITELIST = 'whitelist',
}