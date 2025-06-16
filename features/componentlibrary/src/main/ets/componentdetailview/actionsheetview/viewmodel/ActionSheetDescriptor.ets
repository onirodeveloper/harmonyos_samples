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

import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonDescriptor } from '../../../viewmodel/CommonDescriptor';
import {
  actionSheetInfoMapData,
  autoCancelMapData,
  transitionAppearMapData,
  transitionDisAppearMapData,
  transitionMapData,
} from '../entity/ActionSheetAttributeMapping';

@Observed
export class ActionSheetDescriptor extends CommonDescriptor {
  public autoCancel: boolean = autoCancelMapData.get('Default')!.value;
  public transition: boolean = transitionMapData.get('Default')!.value;
  public sheetInfo: SheetInfo[] = actionSheetInfoMapData.get('Default')!.value;
  public transitionAppear?: TransitionEffect = transitionAppearMapData.get('Default')!.value;
  public transitionDisappear?: TransitionEffect = transitionDisAppearMapData.get('Default')!.value;

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'autoCancel':
          this.autoCancel = JSON.parse(attribute.currentValue);
          break;
        case 'transition':
          this.transition = JSON.parse(attribute.currentValue);
          if (this.transition) {
            this.transitionAppear = transitionAppearMapData.get('Default')!.value;
            this.transitionDisappear = transitionDisAppearMapData.get('Default')!.value;
          } else {
            this.transitionAppear = undefined;
            this.transitionDisappear = undefined;
          }
          break;
        case 'sheetInfo':
          this.sheetInfo = actionSheetInfoMapData.get(attribute.currentValue)?.value ?? this.sheetInfo;
          break;
        default:
          break;
      }
    });
  }
}