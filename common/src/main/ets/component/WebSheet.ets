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

import { StorageKey } from '../constant/CommonEnums';
import type { GlobalInfoModel } from '../model/GlobalInfoModel';
import { BreakpointType } from '../util/BreakpointSystem';
import { WebUtil } from '../util/WebUtil';
import { LoadingView } from '../view/LoadingView';
import { NoNetworkView } from '../view/NoNetworkView';

export enum WebUrlType {
  GITEE = 0,
  HARMONYOS = 1,
}

const GITEE_WEB_BASE_WIDTH: number = 540.00;
const GITEE_TOP_HEIGHT_MD: number = 57;
const GITEE_TOP_HEIGHT_XL: number = 64;
const HARMONYOS_TOP_HEIGHT: number = 56;

@Component
struct WebSheet {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;
  @StorageProp(StorageKey.WEB_LOADING) isLoading: boolean = false;
  @Prop url: string;
  @Prop urlType: WebUrlType;
  @State loadFailed: boolean = false;

  aboutToAppear(): void {
    this.checkWebLoaded();
  }

  checkWebLoaded() {
    if (!WebUtil.checkWebLoaded(this.url)) {
      this.loadFailed = true;
    } else {
      this.loadFailed = false;
    }
  }

  build() {
    Stack() {
      NodeContainer(WebUtil.getWebNode(this.url))
        .width('100%')
        .margin({
          top: -(this.urlType === WebUrlType.GITEE ? new BreakpointType({
            sm: (this.globalInfoModel.deviceWidth / GITEE_WEB_BASE_WIDTH) * GITEE_TOP_HEIGHT_XL,
            md: GITEE_TOP_HEIGHT_MD,
            lg: GITEE_TOP_HEIGHT_MD,
            xl: GITEE_TOP_HEIGHT_XL,
          }).getValue(this.globalInfoModel.currentBreakpoint) : HARMONYOS_TOP_HEIGHT),
        })
      if (this.isLoading) {
        LoadingView(this.globalInfoModel.currentBreakpoint)
      } else if (this.loadFailed) {
        NoNetworkView(this.globalInfoModel.currentBreakpoint, () => {
          this.checkWebLoaded();
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function WebSheetBuilder(url: string, urlType: WebUrlType) {
  Column() {
    WebSheet({ url, urlType })
  }
}