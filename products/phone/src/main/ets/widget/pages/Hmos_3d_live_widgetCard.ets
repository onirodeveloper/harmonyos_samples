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
/** Warning
 * Do NOT import { anything } from '@ohos/common'
 * may cause unexpected problem,
 **/
import { WidgetStaticCard } from '@ohos/widgetcommon';

type AlignParam = Record<string, string | VerticalAlign | HorizontalAlign>;

function setAlignRules(verticalName: string, verticalAlign: VerticalAlign,
  horizontalName: string, horizontalAlign: HorizontalAlign): Record<string, AlignParam> {

  let alignRule: Record<string, AlignParam> = {};
  alignRule[verticalName] = { 'anchor': '__container__', 'align': verticalAlign };
  alignRule[horizontalName] = { 'anchor': '__container__', 'align': horizontalAlign };
  return alignRule;
};

let storageUpdateCall = new LocalStorage();

@Entry(storageUpdateCall)
@Component
struct Hmos_3d_live_widgetCard {
  @LocalStorageProp('formId') formId: string = '';

  build() {
    Stack() {
      WidgetStaticCard()
    } // Stack
    .width('100%')
    .height('100%')
  }
}
