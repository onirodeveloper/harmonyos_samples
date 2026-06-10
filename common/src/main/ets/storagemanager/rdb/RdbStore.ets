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

import { Context } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { taskpool } from '@kit.ArkTS';
import Logger from '../../util/Logger';
import { TableTypeEnum } from './model/TableTypeEnum';

const TAG: string = '[RdbUtil]';
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'hmosWorldDatabase.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

@Concurrent
async function insert(context: Context, data: relationalStore.ValuesBucket, tableName: string,
  config: relationalStore.StoreConfig) {
  try {
    const rdbStore = await relationalStore.getRdbStore(context, config);
    const valueBucket: relationalStore.ValuesBucket = data;
    if (rdbStore) {
      await rdbStore.insert(tableName, valueBucket);
    } else {
      Logger.error('[RdbUtil]', `insert getRdbStore failed. Cause rdbStore is not exist`);
    }
  } catch (error) {
    Logger.error('[RdbUtil]', `insert getRdbStore failed. error: msg ${error.message}, code ${error.code}`);
  }
}

@Concurrent
async function deleteAll(context: Context, tableName: string, config: relationalStore.StoreConfig): Promise<number> {
  try {
    const rdbStore = await relationalStore.getRdbStore(context, config);
    const predicates = new relationalStore.RdbPredicates(tableName);
    if (rdbStore) {
      const rows: number = await rdbStore.delete(predicates);
      return rows;
    }
    return 0;
  } catch (error) {
    Logger.error('[RdbUtil]', `deleteAll getRdbStore failed. error: msg ${error.message}, code ${error.code}`);
    return 0;
  }
}

@Concurrent
async function query(context: Context, tableName: string,
  config: relationalStore.StoreConfig, types: TableTypeEnum[]): Promise<relationalStore.ValuesBucket[]> {
  let resultSet: relationalStore.ResultSet = null!;
  try {
    const rdbStore = await relationalStore.getRdbStore(context, config);
    const predicates = new relationalStore.RdbPredicates(tableName);
    if (rdbStore) {
      resultSet = rdbStore.querySync(predicates);
      const columnNames: string[] = resultSet.columnNames;
      const resArray: relationalStore.ValuesBucket[] = [];
      if (columnNames.length === 0 || resultSet.rowCount === 0) {
        return [];
      }
      resultSet.goToFirstRow();
      do {
        const resultData: relationalStore.ValuesBucket = {};
        columnNames.map((item: string, index: number) => {
          if (types[index] === TableTypeEnum.NUMBER) {
            resultData[item] = resultSet?.getValue(resultSet?.getColumnIndex(item));
          } else if (types[index] === TableTypeEnum.STRING) {
            resultData[item] = resultSet?.getValue(resultSet?.getColumnIndex(item));
          }
        })
        resArray.push(resultData);
      } while (resultSet.goToNextRow());
      resultSet.close();
      return resArray;
    }
    return [];
  } catch (error) {
    resultSet && resultSet.close();
    Logger.error('[RdbUtil]', `query getRdbStore failed. error: msg ${error.message}, code ${error.code}`);
    return [];
  }
}

export class RdbStore {
  private context: Context | undefined;
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private sqlAlertTable: string;
  private types: TableTypeEnum[];

  constructor(tableName: string, sqlCreateTable: string, sqlAlertTable: string, types: TableTypeEnum[]) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.sqlAlertTable = sqlAlertTable;
    this.types = types;
  }

  public async getRdbStore(context: Context): Promise<void> {
    if (this.rdbStore !== null) {
      Logger.info(TAG, 'The rdbStore exists.');
      return;
    }
    this.context = context;
    // Create or open the exist rdb store.
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      if (this.rdbStore) {
        await this.rdbStore.executeSql(this.sqlCreateTable);
      } else {
        Logger.error(TAG, `getRdbStore failed`);
        Promise.reject();
      }
    } catch (err) {
      Logger.error(TAG, `create table fail, cause: ${err.message}`);
      Promise.reject();
    }
  }

  public async insertRdb(data: relationalStore.ValuesBucket): Promise<void> {
    try {
      await taskpool.execute(insert, this.context, data, this.tableName, STORE_CONFIG);
    } catch (err) {
      Logger.error(TAG, `insert data to rdb fail, cause: ${err.message}`);
    }
  }

  public async deleteRdb(): Promise<void> {
    try {
      const rows: number =
        await taskpool.execute(deleteAll, this.context as Context, this.tableName, STORE_CONFIG) as number;
      Logger.info(TAG, `delete the track data of ${rows} lines`);
    } catch (err) {
      Logger.error(TAG, `delete data to rdb fail, cause: ${err.message}`);
    }
  }

  public async query(): Promise<relationalStore.ValuesBucket[]> {
    try {
      const resultSet = await taskpool.execute(query, this.context as Context, this.tableName, STORE_CONFIG,
        this.types) as relationalStore.ValuesBucket[];
      return resultSet;
    } catch (err) {
      return [];
    }
  }

  public async resetId(): Promise<void> {
    try {
      await this.rdbStore?.executeSql(this.sqlAlertTable);
    } catch (err) {
      Logger.error(TAG, `alert table fail, cause: ${err.message}`);
    }
  }
}