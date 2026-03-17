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

import { uri } from '@kit.ArkTS';
import { ImageKnife, ImageKnifeOption } from '@ohos/imageknife';
import { ImageUtil } from './ImageUtil';
import Logger from './Logger';
import { UrlUtil } from './UrlUtil';

const CACHE_SIZE: number = 256;
const CACHE_MEMORY: number = CACHE_SIZE * 1024 * 1024;
const SIG_NAME: string = 'sig';
const TAG: string = '[ImageKnifeUtil]';

export class ImageKnifeUtil {
  public static async initialize(context: Context) {
    try {
      await ImageKnife.getInstance().initFileCache(context, CACHE_SIZE, CACHE_MEMORY);
    } catch (e) {
      Logger.error(TAG, `initFileCache failed. code: ${e.code}; message: ${e.message}`);
    }
  }

  public static preloadImg(mediaUrl: string) {
    if (UrlUtil.isNetUrl(mediaUrl)) {
      const option: ImageKnifeOption = ImageKnifeUtil.getImgOption(mediaUrl);
      ImageKnife.getInstance().preLoadCache(option);
    }
  }

  public static getImgOption(mediaUrl: string): ImageKnifeOption {
    if (!mediaUrl) {
      Logger.error(TAG, `url is empty.`);
      return { loadSrc: '' };
    }
    try {
      const tempUri: uri.URI = new uri.URI(mediaUrl);
      const mediaUri: uri.URI = tempUri.normalize();
      const queryNames: string[] = mediaUri.getQueryNames();
      const queryList: string[] = [];
      // Get url params exclude 'sig'.
      queryNames.forEach((queryName: string) => {
        if (queryName !== SIG_NAME) {
          queryList.push(`${queryName}=${encodeURIComponent(mediaUri.getQueryValue(queryName))}`);
        }
      });
      // Re-splicing media url.
      let imgSrc: string = mediaUri.clearQuery().toString();
      if (queryList.length > 0) {
        imgSrc += `?${queryList.join('&')}`;
      }
      const loadSrc: ResourceStr = ImageUtil.getImgResource(imgSrc);
      const signature: string = mediaUri.getQueryValue(SIG_NAME) || '';
      const option: ImageKnifeOption = { loadSrc };
      if (signature) {
        option.signature = signature;
      }
      return option;
    } catch (error) {
      Logger.error(TAG, `url is invalid. code: ${error.code}; message: ${error.message}`);
      return { loadSrc: '' };
    }
  }
}