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

import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { CommonBoolMapping } from '../../common/entity/CommonMapData';

const TAG: string = '[ActionSheetBuilder]';

class ActionSheetInfoMapping {
  public code: string;
  public value: SheetInfo[];

  public constructor(code: string, value: SheetInfo[]) {
    this.code = code;
    this.value = value;
  }
}

export const autoCancelMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('true', true)],
]);

export const transitionMapData: Map<string, CommonBoolMapping> = new Map([
  ['Default', new CommonBoolMapping('true', true)],
]);

const sheetOne: SheetInfo[] = [
  {
    title: $r('app.string.item1'),
    action: () => {
      try {
        promptAction.showToast({
          message: $r('app.string.item_click', 'item1'),
          duration: DetailPageConstant.LONG_DURATION,
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
      }
    },
  },
  {
    title: $r('app.string.item2'),
    action: () => {
      try {
        promptAction.showToast({
          message: $r('app.string.item_click', 'item2'),
          duration: DetailPageConstant.LONG_DURATION,
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
      }
    },
  },
  {
    title: $r('app.string.item3'),
    action: () => {
      try {
        promptAction.showToast({
          message: $r('app.string.item_click', 'item3'),
          duration: DetailPageConstant.LONG_DURATION,
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Show toast error, the code is ${error.code}}, the message is ${error.message}`);
      }
    },
  },
];

const sheetOneStr: string = `[{
              title: 'item1',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'item1 is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              },
            },
            {
              title: 'item2',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'item2 is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              },
            },
            {
              title: 'item3',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'item3 is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              },
            },]`;

const sheetTwo: SheetInfo[] = [
  {
    title: $r('app.string.apples'),
    action: () => {
      try {
        promptAction.showToast({
          message: $r('app.string.item_click', 'apples'),
          duration: DetailPageConstant.LONG_DURATION,
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Show toast error, the code is ${error.code}, the message is ${error.message}`);
      }
    },
  },
  {
    title: $r('app.string.bananas'),
    action: () => {
      try {
        promptAction.showToast({
          message: $r('app.string.item_click', 'bananas'),
          duration: DetailPageConstant.LONG_DURATION,
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Show toast error, the code is ${error.code}, the message is ${error.message}`);
      }
    },
  },
  {
    title: $r('app.string.pears'),
    action: () => {
      try {
        promptAction.showToast({
          message: $r('app.string.item_click', 'pears'),
          duration: DetailPageConstant.LONG_DURATION,
        });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `Show toast error, the code is ${error.code}, the message is ${error.message}`);
      }
    },
  },
];

const sheetTwoStr: string = `[{
              title: 'apples',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'apples is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              },
            },
            {
              title: 'bananas',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'bananas is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              },
            },
            {
              title: 'pears',
              action: () => {
                try {
                  promptAction.showToast({
                    message: 'pears is clicked',
                    duration: 2000,
                  });
                } catch (err) {
                  const error: BusinessError = err as BusinessError;
                  console.error(\`Show toast error, the code is \${error.code}, the message is \${error.message}\`);
                }
              },
            }]`;

export const actionSheetInfoMapData: Map<string, ActionSheetInfoMapping> = new Map([
  ['Default', new ActionSheetInfoMapping(sheetOneStr, sheetOne)],
  ['sheetInfo1', new ActionSheetInfoMapping(sheetTwoStr, sheetTwo)],
  ['sheetInfo2', new ActionSheetInfoMapping(sheetOneStr, sheetOne)],
]);

const transitionAppearCode: string = `TransitionEffect.OPACITY
                .animation({ duration: 500, curve: Curve.Sharp })
                .combine(TransitionEffect.scale({ x: 1.5, y: 1.5 })
                .animation({ duration: 500, curve: Curve.Sharp }))`;

const transitionDisappearCode: string = `TransitionEffect.OPACITY
                .animation({ duration: 300, curve: Curve.Smooth })
                .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })
                .animation({ duration: 300, curve: Curve.Smooth }))`;

class TransitionMap {
  public code: string;
  public value: TransitionEffect;

  constructor(code: string, value: TransitionEffect) {
    this.code = code;
    this.value = value;
  }
}

export const transitionAppearMapData: Map<string, TransitionMap> = new Map([
  ['Default',
    new TransitionMap(transitionAppearCode,
      TransitionEffect.OPACITY.animation({ duration: DetailPageConstant.ANIMATION_DURATION, curve: Curve.Sharp })
        .combine(TransitionEffect.scale({ x: 1.5, y: 1.5 })
          .animation({ duration: DetailPageConstant.ANIMATION_DURATION, curve: Curve.Sharp })))],
]);

export const transitionDisAppearMapData: Map<string, TransitionMap> = new Map([
  ['Default',
    new TransitionMap(transitionDisappearCode,
      TransitionEffect.OPACITY.animation({ duration: DetailPageConstant.ANIMATION_DURATION_SHORT, curve: Curve.Smooth })
        .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })
          .animation({ duration: DetailPageConstant.ANIMATION_DURATION_SHORT, curve: Curve.Smooth })))],
]);