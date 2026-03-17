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
import { TrackEventType, TrackServiceData } from '../../model/TrackModel';
import Logger from '../../util/Logger';
import { TableTypeEnum } from './model/TableTypeEnum';
import { RdbStore } from './RdbStore';

const TAG: string = '[TrackTable]';

/**
 * Track data table config.
 */
const TRACK_TABLE: TableConfig = {
  tableName: 'trackTable',
  sqlCreate: 'CREATE TABLE IF NOT EXISTS trackTable(id INTEGER PRIMARY KEY AUTOINCREMENT, moduleType INTEGER, ' +
    'eventType VARCHAR(30), operTime VARCHAR(20), content VARCHAR(20), ownerPage VARCHAR(20)) ',
  sqlAlert: 'DELETE FROM sqlite_sequence WHERE name=\'trackTable\'',
  type: [TableTypeEnum.NUMBER, TableTypeEnum.NUMBER, TableTypeEnum.STRING, TableTypeEnum.STRING, TableTypeEnum.STRING,
    TableTypeEnum.STRING],
};

export default class TrackTable {
  private trackTable: RdbStore =
    new RdbStore(TRACK_TABLE.tableName, TRACK_TABLE.sqlCreate, TRACK_TABLE.sqlAlert, TRACK_TABLE.type);

  public constructor(ctx: Context) {
    if (!ctx) {
      Logger.error(TAG, `Constructor TrackTable failed. cause: ctx is undefined.`);
    }
    this.trackTable.getRdbStore(ctx);
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
        moduleType: Reflect.get(item, 'moduleType') as number,
        eventType: Reflect.get(item, 'eventType') as TrackEventType,
        operTime: Reflect.get(item, 'operTime') as string,
        content: Reflect.get(item, 'content') as string,
        ownerPage: Reflect.get(item, 'ownerPage') as string,
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
    trackBucket.moduleType = trackData.moduleType;
    trackBucket.eventType = trackData.eventType;
    trackBucket.operTime = trackData.operTime;
    trackBucket.content = trackData.content;
    trackBucket.ownerPage = trackData.ownerPage;
    return trackBucket;
  }
}

interface TableConfig {
  tableName: string;
  sqlCreate: string;
  sqlAlert: string;
  type: Array<TableTypeEnum>;
}