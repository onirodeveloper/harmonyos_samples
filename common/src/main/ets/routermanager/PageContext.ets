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

import Logger from '../util/Logger';

export interface RouterParam {
  routerName: string;
  param?: object;
}

export interface IPageContext {

  openPage(data: RouterParam, animated?: boolean): void;

  popPage(animated?: boolean): void;

  replacePage(data: RouterParam, animated?: boolean): void;
}

const TAG = '[PageContext]';

export class PageContext implements IPageContext {
  private readonly pathStack: NavPathStack;

  constructor() {
    this.pathStack = new NavPathStack();
  }

  public replacePage(data: RouterParam, animated: boolean = true): void {
    try {
      this.pathStack.replacePath({
        name: data.routerName,
        param: data.param,
      }, animated);
    } catch (err) {
      Logger.error(TAG, `Open Page ${data.routerName} failed. ${err.code} ${err.message}.`);
    }
  }

  public openPage(data: RouterParam, animated: boolean = true): void {
    try {
      this.pathStack.pushPath({
        name: data.routerName,
        param: data.param,
      }, animated);
    } catch (err) {
      Logger.error(TAG, `Open Page ${data.routerName} failed. ${err.code} ${err.message}.`);
    }
  }

  public popPage(animated: boolean = true): void {
    try {
      this.pathStack.pop(animated);
    } catch (err) {
      Logger.error(TAG, `Pop Page failed. ${err.code} ${err.message}.`);
    }
  }

  public get navPathStack(): NavPathStack {
    return this.pathStack;
  }
}