/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../util/Logger';

const TAG = 'RdbUtils';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'database.db',
  securityLevel: relationalStore.SecurityLevel.S1,
};

export class RdbUtils {
  private rdbStore?: relationalStore.RdbStore;
  private tableName: string = '';
  private sqlCreateTable: string = '';
  private context: Context;

  constructor(context: Context, tableName: string, sqlCreateTable: string) {
    this.context = context;
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
  }

  public getRdbStore(): Promise<relationalStore.RdbStore> {
    Logger.info(TAG, `getRdbStore The rdbStore context: ${this.context}`);
    return new Promise<relationalStore.RdbStore>((resolve, reject) => {
      if (this.rdbStore) {
        Logger.info(TAG, 'getRdbStore The rdbStore exists.');
        resolve(this.rdbStore);
      }
      relationalStore
        .getRdbStore(this.context, STORE_CONFIG)
        .then((rdbStore: relationalStore.RdbStore) => {
          Logger.info(TAG, 'getRdbStore successfully.');
          this.rdbStore = rdbStore;
          this.rdbStore.executeSync(this.sqlCreateTable);
          resolve(rdbStore);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `getRdbStore failed, code is ${err.code},message is ${err.message}`);
          reject(err);
        });
    });
  }

  async insertData(valuesBucket: relationalStore.ValuesBucket): Promise<number> {
    Logger.info(TAG, `insertData valuesBucket : ${JSON.stringify(valuesBucket)}`);
    let rdbStore = await this.getRdbStore();
    return new Promise<number>((resolve, reject) => {
      rdbStore
        .insert(this.tableName, valuesBucket)
        .then((rowId: number) => {
          Logger.info(TAG, `insertData successfully. rowId: ${rowId}`);
          resolve(rowId);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `insertData failed, code is ${err.code},message is ${err.message}`);
          reject(err);
        });
    });
  }

  async batchInsert(valueBucketArray: Array<relationalStore.ValuesBucket>): Promise<number> {
    Logger.info(TAG, `batchInsert valuesBucket : ${JSON.stringify(valueBucketArray)}`);
    let rdbStore = await this.getRdbStore();
    return new Promise<number>((resolve, reject) => {
      rdbStore
        .batchInsert(this.tableName, valueBucketArray)
        .then((rowId: number) => {
          Logger.info(TAG, `batchInsert successfully. rowId: ${rowId}`);
          resolve(rowId);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `batchInsert failed, code is ${err.code},message is ${err.message}`);
          reject(err);
        });
    });
  }

  async deleteData(predicates: relationalStore.RdbPredicates): Promise<number> {
    let rdbStore = await this.getRdbStore();
    return new Promise<number>((resolve, reject) => {
      rdbStore
        .delete(predicates)
        .then((rows: number) => {
          Logger.info(TAG, `deleteData successfully. rows: ${rows}`);
          resolve(rows);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `deleteData failed, code is ${err.code},message is ${err.message}`);
          reject(err);
        });
    });
  }

  async updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket): Promise<number> {
    let rdbStore = await this.getRdbStore();
    return new Promise<number>((resolve, reject) => {
      rdbStore
        .update(data, predicates)
        .then((rows: number) => {
          Logger.info(TAG, `updateData successfully. rows: ${rows}`);
          resolve(rows);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `updateData failed, code is ${err.code},message is ${err.message}`);
          reject(err);
        });
    });
  }

  async query(predicates: relationalStore.RdbPredicates): Promise<relationalStore.ResultSet> {
    let rdbStore = await this.getRdbStore();
    return new Promise<relationalStore.ResultSet>((resolve, reject) => {
      rdbStore
        .query(predicates)
        .then((resultSet: relationalStore.ResultSet) => {
          Logger.info(TAG, `query successfully. rowCount: ${resultSet.rowCount}`);
          resolve(resultSet);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `query failed, code is ${err.code},message is ${err.message}`);
          reject(err);
        });
    });
  }
}
