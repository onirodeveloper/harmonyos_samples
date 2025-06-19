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

@Observed
export class TextToSpeechDescriptor extends CommonDescriptor {
  public speed: number = 1;
  public speedType: number = 1;
  public speedArray: string[] = ['0.5倍', '1倍', '1.5倍', '2倍'];

  public convert(attributes: OriginAttribute[]): void {
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'speed':
          this.speedType = this.speedArray.indexOf(attribute.currentValue);
          if (this.speedType === -1) {
            this.speedType = 1;
          }
          this.speed = (this.speedType + 1) * 0.5;
          break;
        default:
          break;
      }
    });
  }
}