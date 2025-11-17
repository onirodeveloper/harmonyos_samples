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
  GlobalInfoModel,
  PageContext,
  PreferenceManager,
  SampleDistributionUtil,
  StorageKey
} from '@ohos/common';
import { AllContentData, SampleContentData } from '../model/AllContentData';
import { MineTrigger } from '../model/NewContentData';
import { NewContentModel } from '../model/NewContentModel';
import { SettingViewBuilder } from '../view/SettingView';
import { BuilderEnum, ListGroup, MineItem, MinePageState } from './MinePageState';

export class MinePageVM extends BaseVM<MinePageState> {
  private static instance: MinePageVM;
  public listGroupData: ListGroup[] = [
    {
      id: 0,
      group: [
        {
          isShow: false,
          textContent: $r('app.string.content_new'),
          symbolSrc: $r('sys.symbol.bell'),
          showTotalNum: true,
          onclick: () => {
            MinePageVM.getInstance().sendEvent(new MinePageEvent('NewContentView'))
          },
          type: BuilderEnum.CARD_ITEM,
        } as MineItem,
        {
          isShow: false,
          textContent: $r('app.string.feedback'),
          symbolSrc: $r('sys.symbol.questionmark_circle'),
          type: BuilderEnum.CARD_ITEM,
          onclick: () => {
          },
        } as MineItem
      ]
    },
    {
      id: 1,
      group: [
        {
          isShow: this.state.aboutViewShow,
          textContent: $r('app.string.setting'),
          symbolSrc: $r('sys.symbol.gearshape'),
          type: BuilderEnum.CARD_ITEM,
          builder: wrapBuilder(SettingViewBuilder),
        } as MineItem
      ]
    }
  ]
  private globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;
  private model: NewContentModel = NewContentModel.getInstance();
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();

  private constructor() {
    super(new MinePageState());
  }

  public static getInstance() {
    if (!MinePageVM.instance) {
      MinePageVM.instance = new MinePageVM();
    }
    return MinePageVM.instance;
  }

  public sendEvent(event: BaseVMEvent | MinePageEvent<pageParams>): void {
    if (event instanceof MinePageEvent) {
      this.jumpToNewPage(event.routerPage, event.params);
    } else if (event instanceof LoadContentNumberEvent) {
      this.loadContentNumber();
    } else if (event instanceof InitEvent) {
      this.assignData();
    }
  }

  private assignData(): void {
    this.state.listItemData = this.listGroupData;
  }

  private jumpToNewPage(page: string, params: pageParams) {
    this.state.newContentNumber = 0;
    this.preferenceManager.setValue('hasViewedNewContent', true);
    const pageContext: PageContext = this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
      AppStorage.get(StorageKey.MINE_PAGE_CONTEXT)! : AppStorage.get(StorageKey.HOME_PAGE_CONTEXT)!;
    pageContext.openPage({
      routerName: page,
      param: params,
    }, true);
  }

  private loadContentNumber(): void {
    const hasResult: boolean = this.preferenceManager.hasValue('hasViewedNewContent');
    if (hasResult) {
      this.state.newContentNumber = 0;
    } else {
      this.model.getNewContentNumber(MineTrigger.ALL_CONTENT).then((res: AllContentData) => {
        let newSampleCount: number = 0;
        res.newSampleInfo.forEach((item: SampleContentData) => {
          if (SampleDistributionUtil.checkSampleSupport(item.requiredApiVersion, item.supportDeviceList)) {
            newSampleCount++;
          }
        });
        this.state.newContentNumber = newSampleCount + res.newArticleInfo.length + res.newComponentInfo.length;
      })
    }
  }
}

export class MinePageEvent<T> {
  public readonly routerPage: string;
  public readonly params?: T;

  constructor(page: string, params?: T) {
    this.routerPage = page;
    this.params = params;
  }
}

export class LoadContentNumberEvent {
  constructor() {
  }
}

export class InitEvent {
  constructor() {
  }
}

export type pageParams = undefined;