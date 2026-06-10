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
import { ImageKnifeUtil, Logger, PageData } from '@ohos/common';
import { BannerData } from '@ohos/commonbusiness';
import { ComponentLibraryService } from '../service/ComponentLibraryService';
import type { ComponentCardData, ComponentData } from './ComponentData';

const TAG = '[ComponentListModel]';

export class ComponentListModel {
  private service: ComponentLibraryService = new ComponentLibraryService();
  private static instance: ComponentListModel;

  private constructor() {
  }

  public static getInstance(): ComponentListModel {
    if (!ComponentListModel.instance) {
      ComponentListModel.instance = new ComponentListModel();
    }
    return ComponentListModel.instance;
  }

  public getComponentPage(currentPage: number, pageSize: number): Promise<PageData<ComponentData>> {
    return this.service.getComponentListByPreference(currentPage, pageSize)
      .then((data: PageData<ComponentData>) => {
        return data;
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `getComponentPage data from network failed! try to get data form preference. ${err.message}`);
        return this.service.getComponentList(currentPage, pageSize)
          .then((data: PageData<ComponentData>) => {
            this.service.setComponentListToPreference(data);
            return data;
          });
      });
  }

  public getComponentBanner(): Promise<BannerData[]> {
    return this.service.getComponentBannerByPreference()
      .then((data: BannerData[]) => {
        return data;
      }).catch((err: BusinessError) => {
        Logger.error(TAG,
          `getComponentPage data from network failed! try to get data form preference. ${err.message}`);
        return this.service.getComponentBanner()
          .then((data: BannerData[]) => {
            this.service.setComponentBannerToPreference(data);
            return data;
          });
      });
  }

  public preloadComponentData(): Promise<void> {
    return new Promise((resolve) => {
      Promise.all([
        this.service.getComponentList(1, 30),
        this.service.getComponentBanner(),
      ])
        .then((result: object) => {
          const cards: PageData<ComponentData> = result[0] as PageData<ComponentData>;
          const banners: BannerData[] = result[1] as BannerData[];
          this.service.setComponentBannerToPreference(banners);
          this.service.setComponentListToPreference(cards);
          banners.forEach((banner: BannerData) => {
            ImageKnifeUtil.preloadImg(banner.mediaUrl);
          });
          cards.data.cardData?.forEach((card: ComponentCardData) => {
            ImageKnifeUtil.preloadImg(card.image);
          });
          resolve();
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG,
            `preloadComponentPage data from network failed. ${err.code}, ${err.message}`);
          resolve();
        });
    });
  }
}