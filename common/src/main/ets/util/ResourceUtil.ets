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
   * Obtains the raw file resource corresponding to the specified resource path.
   * @param context Context.
   * @param path the resource relative path.
   * @returns the raw file resource corresponding to the specified resource path.
   */
  public static getDataFromRawfile(context: Context, path: string): Promise<object> {
    return new Promise((resolve, reject) => {
      if (!context) {
        Logger.error(TAG, 'getDataFromRawfile context is null');
        reject();
        return;
      }
      if (!path || path.length === 0) {
        Logger.error(TAG, 'getDataFromRawfile path is empty or null');
        reject();
        return;
      }
      try {
        const result: Uint8Array = context.resourceManager.getRawFileContentSync(path);
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        const content: string = textDecoder.decodeToString(result, { stream: false });
        if (!content || content.length === 0) {
          Logger.error(TAG, 'getDataFromRawfile content is empty');
          reject();
          return;
        }
        const contentObj = JSON.parse(content);
        if (contentObj) {
          resolve(contentObj);
        } else {
          reject();
        }
      } catch (error) {
        Logger.error(TAG, `getDataFromRawfile failed. ${error.message}`);
        reject();
      }
    });
  }

  /**
   * Obtains the character string corresponding to the specified resource ID.
   *
   * @param resource resource.
   */
  public static getResourceString(context: Context, resource: Resource): string {
    if (!context) {
      Logger.error(TAG, 'getResourceString context is null');
      return '';
    }
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
   * Obtains the DrawableDescriptor of the media file corresponding to a specified resource ID.
   *
   * @param resource DrawableDescriptor.
   */
  public static getDrawableDescriptor(context: Context, resourceId?: number): DrawableDescriptor | undefined {
    try {
      if (!context) {
        Logger.error(TAG, 'getDrawableDescriptor context is null');
        return undefined;
      }
      if (!resourceId) {
        return undefined;
      }
      const drawableDescriptor: DrawableDescriptor = context.resourceManager.getDrawableDescriptor(resourceId);
      return drawableDescriptor;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `[getDrawableDescriptor] getDrawableDescriptor failed, error: ${err.code}, ${err.message}.`);
      return undefined;
    }
  }

  /**
   * Obtains the number result with a specified resource.
   *
   * @param resource resource.
   */
  public static getResourceNumber(context: Context, resource: Resource): number {
    if (!context) {
      Logger.error(TAG, 'getResourceNumber context is null');
      return 0;
    }
    if (ResourceUtil.isEmptyObj(resource)) {
      Logger.error(TAG, '[getResourceNumber] resource is empty.');
      return 0;
    }
    let num: number = 0;
    try {
      num = context.resourceManager.getNumber(resource.id);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `[getResourceNumber] getStringSync failed, error: ${err.code}, ${err.message}.`);
    }
    return num;
  }

  /**
   * Obtains the string array result with a specified resource.
   *
   * @param resource resource.
   */
  public static getResourceStringArray(context: Context, resource: Resource): string[] {
    if (!context) {
      Logger.error(TAG, 'getResourceStringArray context is null');
      return [];
    }
    if (ResourceUtil.isEmptyObj(resource)) {
      Logger.error(TAG, '[getResourceStringArray] resource is empty.');
      return [];
    }
    let strArray: string[] = [];
    try {
      strArray = context.resourceManager.getStringArrayValueSync(resource.id);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `[getResourceStringArray] getStringArrayValueSync failed, error: ${err.code}, ${err.message}.`);
    }
    return strArray;
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
   * Get content from the raw file resource "env.json" by key.
   * @param context The base context of an ability or an application.
   * @param key The Json key value.
   * @returns Return the value of the key.
   */
  public static getRawFileStringByKey(context: Context, key: ConfigMapKey): string | object {
    const configStr: string | object | undefined = AppStorage.get(key);
    if (configStr) {
      return configStr;
    }

    try {
      if (!context) {
        Logger.error(TAG, 'getRawFileStringByKey context is null');
        return '';
      }
      const result: Uint8Array = context.resourceManager.getRawFileContentSync('env.json');
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const content: string = textDecoder.decodeToString(result, { stream: false });
      const jsonContent: ConfigMapData = JSON.parse(content) as ConfigMapData;
      if (JSON.has(jsonContent, key)) {
        const linkUrl: string | object = ResourceUtil.getDataByKey(jsonContent, key);
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

  private static getDataByKey(content: ConfigMapData, key: ConfigMapKey): string | object {
    if (key === ConfigMapKey.GALLERY_URL) {
      return content.galleryUrl;
    } else if (key === ConfigMapKey.MIIT_URL) {
      return content.miitUrl;
    } else if (key === ConfigMapKey.DEVELOPER_URL) {
      return content.developerUrl;
    } else if (key === ConfigMapKey.TV_SOURCE_CODE_URL) {
      return content.tvSourceCodeUrl;
    } else if (key === ConfigMapKey.WHITELIST) {
      return content.webWhitelist;
    } else if (key === ConfigMapKey.JS_WHITELIST) {
      return content.jsWhitelist;
    } else if (key === ConfigMapKey.CONTENT_CENTER) {
      return content.contentCenter;
    }
    return '';
  }

  public static getColorDataByPath(mediaUrl: string): Promise<number[]> {
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    const context: Context | undefined = uiContext?.getHostContext();
    if (!context) {
      Logger.error(TAG, 'getColorDataByPath context is null');
      return Promise.reject({ message: 'getColorDataByPath context is null' } as BusinessError);
    }
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
        Logger.error(TAG, `GetRawFileContent failed, error code: ${error.code}, message: ${error.message}.`);
        reject(error);
      });
    });
  }
}

export class ConfigMapData {
  public galleryUrl: string = '';
  public miitUrl: string = '';
  public tvSourceCodeUrl: string = '';
  public developerUrl: string = '';
  public webWhitelist: object[] = [];
  public jsWhitelist: object[] = [];
  public contentCenter: string = '';
}

export enum ConfigMapKey {
  GALLERY_URL = 'galleryUrl',
  MIIT_URL = 'miitUrl',
  WHITELIST = 'webWhitelist',
  JS_WHITELIST = 'jsWhitelist',
  CONTENT_CENTER = 'contentCenter',
  DEVELOPER_URL = 'developerUrl',
  TV_SOURCE_CODE_URL = 'tvSourceCodeUrl'
}