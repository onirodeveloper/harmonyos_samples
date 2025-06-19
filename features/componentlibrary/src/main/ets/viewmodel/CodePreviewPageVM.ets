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
  BreakpointTypeEnum,
  CommonConstants,
  GlobalInfoModel,
  ModuleNameEnum,
  PageContext,
  ScrollDirectionEnum,
  WebUtil
} from '@ohos/common';
import { CodePreviewState } from './CodePreviewState';
import { DetailPageConstant } from '../constant/DetailPageConstant';

export class CodePreviewPageVM extends BaseVM<CodePreviewState> {
  private static instance: CodePreviewPageVM;
  private globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;

  constructor() {
    super(new CodePreviewState(0, 0, 1));
  }

  public static getInstance(): CodePreviewPageVM {
    if (!CodePreviewPageVM.instance) {
      CodePreviewPageVM.instance = new CodePreviewPageVM();
    }
    return CodePreviewPageVM.instance;
  }

  sendEvent(event: CodePreviewEvent): void {
    if (event === CodePreviewEvent.INIT) {
      this.init();
      this.resetNavigationViewState();
    }
  }

  public pop(animated?: boolean): void {
    const pageContext: PageContext =
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('componentListPageContext')! :
        AppStorage.get('pageContext')!;
    pageContext.popPage(animated);
  }

  private init(): void {
    WebUtil.registerEmitter(ModuleNameEnum.CODE_PREVIEW, this.changeScrollDirection);
  }

  private resetNavigationViewState() {
    this.state.navigationOpacity = 1;
    this.state.topTranslateY = 0;
    this.state.bottomTranslateY = 0;
  }

  private changeScrollDirection = (direction: string, offset: number): void => {
    const globalInfoModel: GlobalInfoModel = AppStorage.get<GlobalInfoModel>('GlobalInfoModel')!;
    if (globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL) {
      return;
    }
    animateTo({
      duration: 300,
      curve: Curve.EaseOut,
    }, () => {
      if (direction === ScrollDirectionEnum.DOWN) {
        this.state.navigationOpacity = 1 - Math.min(offset, DetailPageConstant.CODEPREVIEW_IMMERSIVE_HEIGHT) /
        DetailPageConstant.CODEPREVIEW_IMMERSIVE_HEIGHT;
        const topTranslateY = offset > CommonConstants.NAVIGATION_HEIGHT ? -CommonConstants.NAVIGATION_HEIGHT : -offset;
        const bottomTranslateY = offset > (CommonConstants.TAB_BAR_HEIGHT + globalInfoModel.naviIndicatorHeight) ?
          (CommonConstants.TAB_BAR_HEIGHT + globalInfoModel.naviIndicatorHeight) : offset;
        CommonConstants.TAB_BAR_HEIGHT + globalInfoModel.naviIndicatorHeight;
        this.state.topTranslateY = topTranslateY;
        this.state.bottomTranslateY = bottomTranslateY;
      } else if (direction === ScrollDirectionEnum.UP) {
        this.state.navigationOpacity = 1;
        this.state.topTranslateY = 0;
        this.state.bottomTranslateY = 0;
      }
    })
  }
}

export enum CodePreviewEvent {
  INIT = 'INIT_CODE_PREVIEW_PAGE',
}