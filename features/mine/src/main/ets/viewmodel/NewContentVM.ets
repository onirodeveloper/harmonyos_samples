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

import { BusinessError } from '@kit.BasicServicesKit';
import {
  BaseVM,
  BaseVMEvent,
  InteractionTypeEnum,
  LoadingStatus,
  PageEnum,
  RequestErrorCode,
  TopNavigationData,
} from '@ohos/common';
import {
  ArticleDetailParams,
  CardTypeEnum,
  ComponentDetailParams,
  SampleDetailParams
} from '@ohos/commonbusiness';
import { NewContentData } from '../model/NewContentData';
import { NewContentModel } from '../model/NewContentModel';
import { NewContentPageState } from './NewContentPageState';

export class NewContentVM extends BaseVM<NewContentPageState> {
  private static instance: NewContentVM;
  public segmentItems: ContentSegmentItem[] = [];
  private model: NewContentModel = NewContentModel.getInstance();
  private currentPathStack?: NavPathStack;

  private constructor() {
    super(new NewContentPageState(LoadingStatus.OFF, new TopNavigationData()));
    this.segmentItems = [
      { title: $r('app.string.component'), type: CardTypeEnum.COMPONENT },
      { title: $r('app.string.sample'), type: CardTypeEnum.SAMPLE },
      { title: $r('app.string.article'), type: CardTypeEnum.ARTICLE },
    ];
  }

  public static getInstance(): NewContentVM {
    if (!NewContentVM.instance) {
      NewContentVM.instance = new NewContentVM();
    }
    return NewContentVM.instance;
  }

  public sendEvent(event: BaseVMEvent): void {
    if (event instanceof InitContentNewEvent) {
      this.init(event.type);
    } else if (event instanceof JumpToPage) {
      this.jumpToPage(event.item);
    } else if (event instanceof AssignViewData) {
      this.currentPathStack = event.pathStack;
    } else if (event instanceof PopEvent) {
      this.pop();
    } else if (event instanceof ChangeBackPressed) {
      this.changeBackPressedState(event.backPressed);
    }
  }

  private jumpToPage(item: NewContentData): void {
    let name: string = '';
    let param: ComponentDetailParams | SampleDetailParams | ArticleDetailParams | undefined;
    if (item.contentType === CardTypeEnum.COMPONENT) {
      name = PageEnum.COMPONENT_DETAIL_VIEW;
      param = {
        title: item.title,
        id: item.id,
        interactionType: InteractionTypeEnum.COMPONENT
      } as ComponentDetailParams;
    } else if (item.contentType === CardTypeEnum.SAMPLE) {
      name = PageEnum.SAMPLE_DETAIL_VIEW;
      param = {
        title: item.title,
        currentIndex: (item.sequence - 1) ?? 0,
        cardId: item.cardId,
        id: item.id,
        interactionType: InteractionTypeEnum.SAMPLE,
        unionId: item.unionId,
        categoryName: item.categoryName,
      } as SampleDetailParams;
    } else if (item.contentType === CardTypeEnum.ARTICLE) {
      name = PageEnum.ARTICLE_DETAIL_VIEW;
      param = {
        id: item.id,
        title: item.title,
        isArticle: true,
        detailsUrl: item.detailsUrl || '',
        interactionType: InteractionTypeEnum.ARTICLE,
      } as ArticleDetailParams;
    }
    this.currentPathStack?.pushPath({ name, param }, true);
  }

  private init(index: number): void {
    this.initTopNavigationData();
    this.state.loadingStatus = LoadingStatus.LOADING;
    this.state.newComponentData = [];
    this.state.newSampleData = [];
    this.state.newArticleData = [];
    this.model.getNewContent(this.segmentItems[index].type)
      .then((res: NewContentData[]) => {
        const contentList: NewContentData[] = [];
        res.forEach((item: NewContentData) => {
          contentList.push({
            id: item.id,
            cardId: item.cardId,
            unionId: item.unionId,
            title: item.title,
            contentType: item.contentType,
            subTitle: item.subTitle as string,
            sequence: item.sequence,
            detailsUrl: item.detailsUrl,
          } as NewContentData);
        });
        switch (index) {
          case 0:
            this.state.newComponentData = contentList;
            break;
          case 1:
            this.state.newSampleData = contentList;
            break;
          case 2:
            this.state.newArticleData = contentList;
            break;
          default:
            break;
        }
        this.state.loadingStatus = LoadingStatus.SUCCESS;
      })
      .catch((error: BusinessError) => {
        if (error.code === RequestErrorCode.NETWORK_CONNECT_FAILED) {
          this.state.loadingStatus = LoadingStatus.NO_NETWORK;
        } else {
          this.state.loadingStatus = LoadingStatus.FAILED;
        }
      });
  }

  private initTopNavigationData(): void {
    this.state.topNavigationData = {
      title: $r('app.string.content_new'),
      titleColor: $r('sys.color.font_primary'),
      isFullScreen: true,
      isBlur: false,
      onBackClick: () => {
        this.pop();
      },
    };
  }

  private pop(): void {
    this.changeBackPressedState(true);
    this.currentPathStack?.pop()
  }

  private changeBackPressedState(backPressed: boolean) {
    this.state.isBackPressed = backPressed;
  }
}

export class AssignViewData implements BaseVMEvent {
  public pathStack: NavPathStack;

  constructor(pathStack: NavPathStack) {
    this.pathStack = pathStack;
  }
}

export class InitContentNewEvent implements BaseVMEvent {
  public type: number;

  constructor(type: number) {
    this.type = type;
  }
}

export class JumpToPage implements BaseVMEvent {
  public item: NewContentData;

  constructor(item: NewContentData) {
    this.item = item;
  }
}

export class PopEvent implements BaseVMEvent {
}

export class ChangeBackPressed implements BaseVMEvent {
  public readonly backPressed: boolean;

  constructor(backPressed: boolean) {
    this.backPressed = backPressed;
  }
}

export interface ContentSegmentItem {
  title: Resource;
  type: CardTypeEnum;
}