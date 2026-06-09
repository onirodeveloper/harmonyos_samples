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
import { GlobalInfoModel } from '../model/GlobalInfoModel';
import { WebUtil } from '../util/WebUtil';
import { LoadingView } from '../view/LoadingView';
import { NoNetworkView } from '../view/NoNetworkView';

export enum WebUrlType {
  GITCODE = 0,
  HARMONYOS = 1,
}

const GITCODE_TOP_HEIGHT: number = 57;
const HARMONYOS_TOP_HEIGHT: number = 56;

@Component
struct WebSheet {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = new GlobalInfoModel();
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
          top: -(this.urlType === WebUrlType.GITCODE ? GITCODE_TOP_HEIGHT : HARMONYOS_TOP_HEIGHT),
        })
      if (this.isLoading) {
        LoadingView(this.globalInfoModel.widthBreakpoint)
      } else if (this.loadFailed) {
        NoNetworkView(this.globalInfoModel.widthBreakpoint, () => {
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