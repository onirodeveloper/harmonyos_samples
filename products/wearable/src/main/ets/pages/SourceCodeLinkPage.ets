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
import { QRCodeComponent } from '../component/QRCodeComponent';
import { SourceCodeLinkPageParam } from '../viewmodel/SampleListViewModel';

@Component
export struct SourceCodeLinkPage {
  private webviewUrl: string = '';
  private title: string = '';

  handleOnReady(cxt: NavDestinationContext) {
    const params = cxt.pathInfo.param as SourceCodeLinkPageParam;
    this.webviewUrl = params.sourceCodeLink;
    this.title = params.title;
  }

  build() {
    NavDestination() {
      QRCodeComponent({ webviewUrl: this.webviewUrl, title: this.title})
    }
    .width(`100%`)
    .height(`100%`)
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
  }
}

@Builder
export function SourceCodeLinkPageBuilder() {
  SourceCodeLinkPage()
}