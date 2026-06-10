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

import { BaseVM, BaseVMEvent, Logger } from '@ohos/common';
import { ALL_ARTICLE_LISTS, ArticleListItem, ArticleServiceCardState } from '@ohos/widgetcommon';

const TAG: string = '[ArticleServiceCardVM]';

export class ArticleServiceCardVM extends BaseVM<ArticleServiceCardState> {
  private static instance: ArticleServiceCardVM;

  private constructor(cardList: ArticleListItem[]) {
    super(new ArticleServiceCardState(cardList, new Map()));
  }

  public static getInstance() {
    if (!ArticleServiceCardVM.instance) {
      ArticleServiceCardVM.instance = new ArticleServiceCardVM([]);
    }
    return ArticleServiceCardVM.instance;
  }

  sendEvent(event: BaseVMEvent | InitEvent): void {
    if (event instanceof InitEvent) {
      this.init();
    } else if (event instanceof UpdateDataEvent) {
      this.updateData(event.formId);
    } else if (event instanceof AddFormData) {
      this.addFormData(event.formId, event.data);
    } else if (event instanceof RemoveFormData) {
      this.removeFormData(event.formId);
    }
  }

  private init(): void {
    this.state.cardList = this.getRandomThreeArticle([]);
  }

  private updateData(formId: string): void {
    const currentDataOfFormId: ArticleListItem[] = this.state.formDataRecord.get(formId) ?? [];
    Logger.debug(TAG, `The currentDataOfFormId is ${JSON.stringify(currentDataOfFormId)} in updateData.`);
    this.removeFormData(formId);
    const newDataOfFormId: ArticleListItem[] = this.getRandomThreeArticle(currentDataOfFormId);
    this.state.cardList = newDataOfFormId;
    this.addFormData(formId, newDataOfFormId);
  }

  private getRandomThreeArticle(exclude: ArticleListItem[]): ArticleListItem[] {
    const articles = [...ALL_ARTICLE_LISTS];
    const selected: ArticleListItem[] = [];
    exclude.forEach((item: ArticleListItem) => {
      const index: number = articles.findIndex((article: ArticleListItem) => article.id === item.id);
      articles.splice(index, 1);
    })
    while (selected.length < 3) {
      const randomIndex = Math.floor(Math.random() * articles.length);
      const articleInfo: ArticleListItem = articles[randomIndex];
      if (selected.filter((item: ArticleListItem) => item.id === articleInfo.id).length === 0) {
        selected.push(articleInfo);
        articles.splice(randomIndex, 1);
      }
    }
    return selected;
  }

  private addFormData(formId: string, data: ArticleListItem[]) {
    this.state.formDataRecord.set(formId, data);
  }

  private removeFormData(formId: string) {
    if (this.state.formDataRecord.has(formId)) {
      this.state.formDataRecord.delete(formId);
    }
  }
}

export class InitEvent implements BaseVMEvent {
}

export class UpdateDataEvent implements BaseVMEvent {
  public readonly formId: string = '';

  constructor(formId: string) {
    this.formId = formId;
  }
}

export class AddFormData implements BaseVMEvent {
  public readonly formId: string = '';
  public readonly data: ArticleListItem[] = [];

  constructor(formId: string, data: ArticleListItem[]) {
    this.formId = formId;
    this.data = data;
  }
}

export class RemoveFormData implements BaseVMEvent {
  public readonly formId: string = '';

  constructor(formId: string) {
    this.formId = formId;
  }
}