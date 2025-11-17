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

import {
  BaseVM,
  BaseVMEvent,
  LoadingStatus,
  ResponseData,
  SampleDistributionUtil,
  TopNavigationData
} from '@ohos/common';
import { ArticleDetailParams, CardTypeEnum, ComponentDetailParams, SampleDetailParams } from '@ohos/commonbusiness';
import { MineTrigger, NewContentData } from '../model/NewContentData';
import { NewContentModel } from '../model/NewContentModel';
import { NewContentPageState } from './NewContentPageState';

export class NewContentVM extends BaseVM<NewContentPageState> {
  private static instance: NewContentVM;
  public segmentItems: SegmentItem[] = [];
  public newComponentData: ContentData[] = [];
  public newSampleData: ContentData[] = [];
  public newArticleData: ContentData[] = [];
  private model: NewContentModel = NewContentModel.getInstance();
  private pageSize: number = 30;
  private currentPathStack?: NavPathStack;

  private constructor() {
    super(new NewContentPageState(LoadingStatus.OFF, new TopNavigationData(), 1));
    this.segmentItems = [
      { title: $r('app.string.component'), trigger: MineTrigger.NEW_COMPONENT },
      { title: $r('app.string.sample'), trigger: MineTrigger.NEW_SAMPLE },
      { title: $r('app.string.article'), trigger: MineTrigger.NEW_ARTICLE },
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
    }
  }

  private jumpToPage(item: ContentData): void {
    let param: NewContentPageParams;
    let name: string = '';
    if (item.type === CardTypeEnum.COMPONENT) {
      name = RouterName.COMPONENT_DETAIL_VIEW;
      param = { componentName: item.title, componentId: item.id };
    } else if (item.type === CardTypeEnum.SAMPLE) {
      name = RouterName.SAMPLE_DETAIL_VIEW;
      param = { currentIndex: item.currentIndex ?? 0, sampleCardId: item.id };
    } else if (item.type === CardTypeEnum.ARTICLE) {
      name = RouterName.ARTICLE_DETAIL_VIEW;
      param = {
        id: item.id,
        title: item.title,
        isArticle: true,
        detailsUrl: item.detailsUrl || '',
      };
    }
    this.currentPathStack?.pushPath({ name, param }, true);
  }

  private init(index: number): void {
    this.initTopNavigationData();
    this.state.loadingStatus = LoadingStatus.LOADING;
    this.newComponentData = [];
    this.newSampleData = [];
    this.newArticleData = [];
    this.model.getNewContent(this.segmentItems[index].trigger, this.state.currentPage, this.pageSize)
      .then((res: ResponseData<NewContentData[]>) => {
        const contentList: ContentData[] = [];
        res.data.forEach((item: NewContentData) => {
          if (item.type === CardTypeEnum.SAMPLE &&
          SampleDistributionUtil.checkSampleSupport(item.requiredApiVersion ?? 0, item.supportDeviceList ?? [])) {
            contentList.push({
              id: item.id,
              title: item.title,
              type: item.type,
              subTitle: item.subTitle as string,
              currentIndex: item.currentIndex,
              detailsUrl: item.detailsUrl,
            } as ContentData);
          }
        });
        switch (index) {
          case 0:
            this.newComponentData = contentList;
            break;
          case 1:
            this.newSampleData = contentList;
            break;
          case 2:
            this.newArticleData = contentList;
            break;
          default:
            break;
        }
        this.state.loadingStatus = LoadingStatus.SUCCESS;
      })
      .catch(() => {
        this.state.loadingStatus = LoadingStatus.FAILED;
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
    this.currentPathStack?.pop()
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
  public item: ContentData;

  constructor(item: ContentData) {
    this.item = item;
  }
}

export enum RouterName {
  COMPONENT_DETAIL_VIEW = 'ComponentDetailView',
  SAMPLE_DETAIL_VIEW = 'SampleDetailView',
  ARTICLE_DETAIL_VIEW = 'ArticleDetailView',
}

export interface SegmentItem {
  title: Resource;
  trigger: MineTrigger;
}

export class ContentData {
  public id: number = 0;
  public title: string = '';
  public type: CardTypeEnum = CardTypeEnum.UNKNOWN;
  public subTitle?: string = '';
  public detailsUrl?: string = '';
  public isArticle?: boolean = true;
  public currentIndex?: number = 0;
}

export type NewContentPageParams = ComponentDetailParams | SampleDetailParams | ArticleDetailParams | undefined;