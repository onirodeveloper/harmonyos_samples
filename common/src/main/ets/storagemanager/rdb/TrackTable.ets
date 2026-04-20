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

import { relationalStore } from '@kit.ArkData';
import { MainTabEnum, ReferTypeEnum, TrackEventType, TrackServiceData } from '../../model/TrackModel';
import Logger from '../../util/Logger';
import { TableTypeEnum } from './model/TableTypeEnum';
import { RdbStore } from './RdbStore';

const TAG: string = '[TrackTable]';

/**
 * Track data table config.
 */
const TRACK_TABLE: TableConfig = {
  tableName: 'trackTable',
  sqlCreate: 'CREATE TABLE IF NOT EXISTS trackTable(id INTEGER PRIMARY KEY AUTOINCREMENT, eventType VARCHAR(20),' +
    'interactionType VARCHAR(20), time VARCHAR(20), interactionContent VARCHAR(20), pageName VARCHAR(20),' +
    'mainTab VARCHAR(20), secondaryTab VARCHAR(20), actionName VARCHAR(30), referType VARCHAR(30), ' +
    'referSourceId VARCHAR(30), duration INTEGER, pushMessageTitle VARCHAR(30))',
  sqlAlert: 'DELETE FROM sqlite_sequence WHERE name=\'trackTable\'',
  type: [
    TableTypeEnum.NUMBER, TableTypeEnum.STRING, TableTypeEnum.STRING, TableTypeEnum.STRING, TableTypeEnum.STRING,
    TableTypeEnum.STRING, TableTypeEnum.STRING, TableTypeEnum.STRING, TableTypeEnum.STRING, TableTypeEnum.STRING,
    TableTypeEnum.STRING, TableTypeEnum.NUMBER, TableTypeEnum.STRING
  ],
};

export default class TrackTable {
  private trackTable: RdbStore =
    new RdbStore(TRACK_TABLE.tableName, TRACK_TABLE.sqlCreate, TRACK_TABLE.sqlAlert, TRACK_TABLE.type);

  public constructor() {
  }

  public async getRdbStore(ctx: Context) {
    if (!ctx) {
      Logger.error(TAG, `Constructor TrackTable failed. cause: ctx is undefined.`);
    }
    await this.trackTable.getRdbStore(ctx);
  }

  public insertTrackData(trackData: TrackServiceData): void {
    const valueBucket: relationalStore.ValuesBucket = this.generateBucket(trackData);
    this.trackTable.insertRdb(valueBucket);
  }

  /**
   * delete all track data.
   */
  public async deleteTrackData(): Promise<void> {
    try {
      await this.trackTable.deleteRdb();
      await this.resetId();
    } catch (e) {
      Logger.error(TAG, `deleteTrackData failed. cause: ${e.message}`);
    }
  }

  /**
   * query all service data from rdb.
   *
   * @param callback
   */
  public async queryAll(): Promise<TrackServiceData[]> {
    const trackServiceDataArray: TrackServiceData[] = [];
    const resArray = await this.trackTable.query() as Array<Record<string, string | number>>;
    resArray.forEach((item: Record<string, string | number>) => {
      trackServiceDataArray.push({
        eventType: Reflect.get(item, 'eventType') as TrackEventType,
        pageName: Reflect.get(item, 'pageName') as string,
        mainTab: Reflect.get(item, 'mainTab') as MainTabEnum,
        secondaryTab: Reflect.get(item, 'secondaryTab') as string,
        interactionType: Reflect.get(item, 'interactionType') as string,
        interactionContent: Reflect.get(item, 'interactionContent') as string,
        actionName: Reflect.get(item, 'actionName') as string,
        referType: Reflect.get(item, 'referType') as ReferTypeEnum,
        time: Reflect.get(item, 'time') as string,
        duration: Reflect.get(item, 'duration') as number,
        pushMessageTitle: Reflect.get(item, 'pushMessageTitle') as string,
      })
    })
    return trackServiceDataArray;
  }

  private async resetId(): Promise<void> {
    await this.trackTable.resetId();
  }

  /**
   * Convert the TrackTableData type to relationalStore.ValuesBucket type.
   *
   * @param trackData
   * @returns
   */
  private generateBucket(trackData: TrackServiceData): relationalStore.ValuesBucket {
    const trackBucket: relationalStore.ValuesBucket = {};
    trackBucket.eventType = trackData.eventType ?? TrackEventType.UNKNOWN;
    trackBucket.pageName = trackData.pageName ?? '';
    trackBucket.mainTab = trackData.mainTab ?? MainTabEnum.UNKNOWN;
    trackBucket.secondaryTab = trackData.secondaryTab ?? '';
    trackBucket.interactionType = trackData.interactionType ?? '';
    trackBucket.interactionContent = trackData.interactionContent ?? '';
    trackBucket.actionName = trackData.actionName ?? '';
    trackBucket.referType = trackData.referType ?? ReferTypeEnum.UNKNOWN;
    trackBucket.referSourceId = trackData.referSourceId ?? '';
    trackBucket.time = trackData.time ?? '';
    trackBucket.duration = trackData.duration ?? -1;
    trackBucket.pushMessageTitle = trackData.pushMessageTitle ?? '';
    return trackBucket;
  }
}

interface TableConfig {
  tableName: string;
  sqlCreate: string;
  sqlAlert: string;
  type: Array<TableTypeEnum>;
}