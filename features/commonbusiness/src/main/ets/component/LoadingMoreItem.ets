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

import type { LoadingModel } from '@ohos/common';
import { LoadingMore, LoadingStatus, NoMore } from '@ohos/common';

@Builder
export function LoadingMoreItemBuilder(loadingModel: LoadingModel) {
  Column() {
    if (loadingModel.loadingMoreStatus === LoadingStatus.LOADING) {
      LoadingMore()
    } else if (!loadingModel.hasNextPage) {
      NoMore()
    }
  }
  .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
}