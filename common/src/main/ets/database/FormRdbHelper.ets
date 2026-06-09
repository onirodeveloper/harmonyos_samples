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
import Logger from '../util/Logger';
import { FormInfo } from '../viewmodel/FormInfo';
import { RdbUtils } from './RdbUtils';

const TAG = 'FormRdbHelper';

const SQL_CREATE_TABLE: string = 'CREATE TABLE IF NOT EXISTS FormInfoTable(formId STRING PRIMARY KEY, formName STRING, formDimension STRING)';

const TABLE_NAME = 'FormInfoTable';
let rdbUtils: RdbUtils;

export class FormRdbHelper {
  private static instance: FormRdbHelper;

  private constructor(context: Context) {
    Logger.info(TAG, `constructor Context: ${context}`);
    rdbUtils = new RdbUtils(context, TABLE_NAME, SQL_CREATE_TABLE);
  }

  public static getInstance(context: Context): FormRdbHelper {
    if (!FormRdbHelper.instance) {
      FormRdbHelper.instance = new FormRdbHelper(context);
    }
    return FormRdbHelper.instance;
  }

  public insertForm(formInfo: FormInfo): Promise<number> {
    Logger.info(TAG, `insertForm formInfo: ${JSON.stringify(formInfo)}`);
    let valueBucket = this.generateBucket(formInfo);
    return rdbUtils.insertData(valueBucket);
  }

  public deleteForm(formId: string): Promise<number> {
    Logger.info(TAG, `deleteForm formId: ${formId}`);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('formId', formId);
    return rdbUtils.deleteData(predicates);
  }

  public updateForm(formInfo: FormInfo): Promise<number> {
    Logger.info(TAG, `updateForm formId: ${formInfo.formId}`);
    let valueBucket = this.generateBucket(formInfo);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('formId', formInfo.formId);
    return rdbUtils.updateData(predicates, valueBucket);
  }

  public queryAllForm(): Promise<Array<FormInfo>> {
    Logger.info(TAG, 'queryAllForm');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    return this.queryForm(predicates);
  }

  public queryFormByName(formName: string): Promise<Array<FormInfo>> {
    Logger.info(TAG, 'queryAllForm');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.contains('formName', formName);
    return this.queryForm(predicates);
  }

  public queryFormById(formId: string): Promise<FormInfo> {
    Logger.info(TAG, `queryFormById formId: ${formId}`);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('formId', formId);
    return new Promise<FormInfo>(async (resolve) => {
      let formInfoList = await this.queryForm(predicates);
      if (formInfoList.length > 0) {
        resolve(formInfoList[0]);
      }
    });
  }

  public queryForm(predicates: relationalStore.RdbPredicates): Promise<Array<FormInfo>> {
    Logger.info(TAG, 'queryForm');
    return new Promise<Array<FormInfo>>(async (resolve) => {
      let formInfoList: FormInfo[] = [];
      let resultSet = await rdbUtils.query(predicates);
      while (resultSet.goToNextRow()) {
        let formInfo: FormInfo = new FormInfo();
        formInfo.formId = resultSet.getString(resultSet.getColumnIndex('formId'));
        formInfo.formName = resultSet.getString(resultSet.getColumnIndex('formName'));
        formInfo.formDimension = resultSet.getString(resultSet.getColumnIndex('formDimension'));
        formInfoList.push(formInfo);
      }
      resultSet.close();
      Logger.info(TAG, `queryForm formInfoList: ${JSON.stringify(formInfoList)}`);
      resolve(formInfoList);
    });
  }

  private generateBucket(formInfo: FormInfo): relationalStore.ValuesBucket {
    let valueBucket: relationalStore.ValuesBucket = {
      formId: formInfo.formId,
      formName: formInfo.formName,
      formDimension: formInfo.formDimension,
    };
    return valueBucket;
  }
}
