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

import { ArticleListItem, ArticleCardComponent, FormCardEnum } from '@ohos/widgetcommon';

@Entry
@Component
struct ArticleServiceCard {
  @LocalStorageProp('cardList') cardList: ArticleListItem[] = [];
  @LocalStorageProp('formId') formId: string = '';
  build() {
    Row() {
      ArticleCardComponent({
        cardList: this.cardList,
        onClickProcess: (item?: ArticleListItem) => {
          this.onClickProcess(item)
        }
      })
    }
    .height('100%')
    .width('100%')
    .onClick(() => this.onClickProcess())
  }

  private onClickProcess = (articleInfo?: ArticleListItem) => {
    postCardAction(this, {
      action: 'router',
      abilityName: 'PcAbility',
      params: {
        formId: this.formId,
        articleInfo: articleInfo,
        cardFrom: FormCardEnum.ARTICLE_SERVICE_CARD,
      }
    })
  }
}