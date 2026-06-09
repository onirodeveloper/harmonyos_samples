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

import { UIContext, uiObserver } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { StorageKey } from '../constant/CommonEnums';
import { PageEnum } from '../model/PageEnum';
import { BundleInfoData } from '../model/BundleInfoData';
import { TRACK_KEY, TrackCommonData, TrackEventType, TrackModel, TrackServiceData } from '../model/TrackModel';
import { PreferenceManager } from '../storagemanager/PreferenceManager';
import TrackTable from '../storagemanager/rdb/TrackTable';
import { FormatDate } from '../util/DateFormatUtil';
import Logger from '../util/Logger';
import { TrackService } from './TrackService';

const TAG = '[TrackManager]';
const TIMEOUT: number = 60000;
const MAX_LIMIT: number = 1000;

export class TrackManager {
  private static instance: TrackManager;
  private static uiContext: UIContext;
  private static trackTable: TrackTable;
  private trackCommonData: TrackCommonData | undefined;
  private interval: number = 0;
  private currentPage: string = PageEnum.MAIN_PAGE;
  private pageSwitchInTime: number = -1;

  private constructor() {
  }

  public static getInstance(): TrackManager {
    if (!TrackManager.instance) {
      TrackManager.instance = new TrackManager();
    }
    return TrackManager.instance;
  }

  /**
   * Init the track service, register the uiObserver 'willClick' and 'navigationSwitch' event.
   */
  public initTrackManager(): void {
    PreferenceManager.getInstance().setValue<TrackModel[]>(StorageKey.APP_TRACK_DATA, []);
    this.initTrackCommonData().then(async () => {
      TrackManager.uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
      TrackManager.trackTable = new TrackTable();
      try {
        await TrackManager.trackTable.getRdbStore(TrackManager.uiContext?.getHostContext() as Context)
        // If not exist the account user id, then generate guest id.
        this.startReporting(TIMEOUT);
        this.registerClickListen();
        this.registerNavigationListen();
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.info(TAG, `get rdb store error, cause: ${err.message}`);
      }
    });
  }

  /**
   * Deinit the track service, unregister the uiObserver 'willClick' and 'navigationSwitch' event.
   */
  public offTrackManager(): void {
    this.stopReporting();
    this.unRegisterClickListen();
    this.unRegisterNavigationListen();
  }

  public reportData(trackServiceData: TrackServiceData): void {
    if (trackServiceData.pageName === undefined) {
      trackServiceData.pageName = this.currentPage;
    }
    trackServiceData.pageName = trackServiceData.pageName !== '' ? trackServiceData.pageName : null;
    trackServiceData.time = FormatDate.formatDate(new Date());
    trackServiceData.interactionContent =
      trackServiceData.interactionContent !== '' ? trackServiceData.interactionContent : null;
    TrackManager.trackTable.insertTrackData(trackServiceData);
  }

  /**
   * Get the actual child click node.
   *
   * @param node
   * @returns
   */
  public getChildFrameNode(node: FrameNode): FrameNode | null {
    if (node?.getCustomProperty(TRACK_KEY)) {
      return node;
    }
    for (let i = 0; i < node?.getChildrenCount(); i++) {
      const child = node?.getChild(i) as FrameNode;
      if (child) {
        const result = this.getChildFrameNode(child);
        if (result) {
          return result;
        }
      }
    }
    return null;
  }

  /**
   * Get the actual parent click node.
   *
   * @param node
   * @returns
   */
  public getParentFrameNode(node: FrameNode): FrameNode | null {
    if (node === null) {
      return null;
    }
    if (node?.getCustomProperty(TRACK_KEY)) {
      return node;
    }
    return this.getParentFrameNode(node?.getParent() as FrameNode);
  }

  private registerClickListen(): void {
    TrackManager.uiContext.getUIObserver().on('willClick', (_event: ClickEvent, node?: FrameNode) => {
      if (node) {
        const actualNode: FrameNode | null = this.getChildFrameNode(node) || this.getParentFrameNode(node);
        const trackServiceData = actualNode?.getCustomProperty(TRACK_KEY) as TrackServiceData;
        if (trackServiceData) {
          trackServiceData.eventType = TrackEventType.CLICK;
          this.reportData(trackServiceData);
        }
      }
    })
  }

  private registerNavigationListen(): void {
    TrackManager.uiContext.getUIObserver()
      .on('navDestinationSwitch', (navigationInfo: uiObserver.NavDestinationSwitchInfo) => {
        const from: uiObserver.NavDestinationInfo = navigationInfo.from;
        if (from.name) {
          if (from.name === this.currentPage) {
            this.assignNavigationTrackData(from, TrackEventType.EXPOSURE);
          }
          this.currentPage = (navigationInfo.to as uiObserver.NavDestinationInfo).name as string;
        }
        this.pageSwitchInTime = Date.now();
      })
  }

  private unRegisterClickListen(): void {
    TrackManager.uiContext?.getUIObserver()?.off('willClick');
  }

  private unRegisterNavigationListen(): void {
    TrackManager.uiContext?.getUIObserver()?.off('navDestinationSwitch');
  }

  /**
   * Get the common track data.
   */
  private initTrackCommonData(): Promise<void> {
    return Promise.resolve().then(() => {
      const bundleInfo: BundleInfoData | undefined = AppStorage.get(StorageKey.BUNDLE_INFO);
      const trackCommonData: TrackCommonData = {
        bundleName: bundleInfo?.bundleName ?? null,
        version: bundleInfo?.versionCode ?? 0,
        deviceType: deviceInfo.deviceType ?? null,
        apiVersion: deviceInfo.sdkApiVersion,
      }
      this.trackCommonData = trackCommonData;
    })
  }

  private assignNavigationTrackData(currentPageInfo: uiObserver.NavDestinationInfo, eventType: TrackEventType): void {
    if (currentPageInfo.name === undefined) {
      return;
    }
    const pageName: string = currentPageInfo.name as string;
    let interactionType: string | null = null;
    let interactionContent: string | null = null;
    if (currentPageInfo.param) {
      interactionType = Reflect.get(currentPageInfo.param, 'interactionType');
      interactionContent = Reflect.get(currentPageInfo.param, 'title');
    }
    // Only record the detail page.
    const trackServiceData: TrackServiceData = {
      interactionType,
      interactionContent,
      pageName,
      eventType,
      duration: Date.now() - this.pageSwitchInTime,
    } as TrackServiceData;
    this.pageSwitchInTime = Date.now();
    this.reportData(trackServiceData);
  }

  /**
   * Start the report track data by time interval.
   *
   * @param interval
   */
  private startReporting(interval: number): void {
    this.interval = setInterval(() => {
      TrackManager.trackTable.queryAll().then((res: TrackServiceData[]) => {
        if (res.length !== 0) {
          Logger.info(TAG, `The cachedData length is ${res.length}`);
          const cachedData = res.map((item: TrackServiceData) => {
            return new TrackModel(this.trackCommonData as TrackCommonData, item)
          });
          TrackService.postTrackData(cachedData).then(async () => {
            // Reset the track data.
            await TrackManager.trackTable.deleteTrackData();
          }).catch(async () => {
            // More than MAX_LIMIT, then clear the database
            if (res.length > MAX_LIMIT) {
              await TrackManager.trackTable.deleteTrackData();
            }
          });
        }
      });
    }, interval);
  }

  private stopReporting(): void {
    clearInterval(this.interval);
    this.interval = 0;
  }
}