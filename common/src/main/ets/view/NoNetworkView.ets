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

import type { common, Want } from '@kit.AbilityKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constant/CommonConstants';
import { ColumnEnum } from '../constant/CommonEnums';
import { BreakpointTypeEnum } from '../model/GlobalInfoModel';
import { BreakpointType } from '../util/BreakpointSystem';
import Logger from '../util/Logger';

const TAG = '[NoNetworkView]';

@Builder
export function NoNetworkView(breakpoint: BreakpointTypeEnum, handleReload?: () => void) {
  GridRow({ columns: { sm: ColumnEnum.SM, md: ColumnEnum.MD, lg: ColumnEnum.LG } }) {
    GridCol({
      span: { sm: CommonConstants.SPACE_4, md: CommonConstants.SPAN_6, lg: CommonConstants.SPAN_6 },
      offset: { sm: 0, md: 1, lg: CommonConstants.SPAN_3 },
    }) {
      Column() {
        Row()
          .height($r('app.float.loading_size_sm'))
        Column() {
          Image($r('app.media.ic_failure'))
            .draggable(false)
            .width(new BreakpointType({
              sm: $r('app.float.failure_size_sm'),
              md: $r('app.float.failure_size_md'),
              lg: $r('app.float.failure_size_lg'),
            }).getValue(breakpoint))
            .aspectRatio(1)
          Text($r('app.string.network_error'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .margin({ top: $r('sys.float.padding_level4') })
        }

        Button($r('app.string.network_setting'),
          { buttonStyle: ButtonStyleMode.NORMAL, controlSize: ControlSize.NORMAL })
          .width('100%')
          .onClick(() => {
            const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
            const want: Want = {
              bundleName: 'com.huawei.hmos.settings',
              abilityName: 'com.huawei.hmos.settings.MainAbility',
              uri: 'wifi_entry',
            };
            try {
              context.startAbility(want).then(() => {
                Logger.info(TAG, `start setting ability succeed. `);
              }).catch((err: BusinessError) => {
                Logger.error(TAG, `start setting ability failed. ${err.code}, ${err.message}.`);
              });
            } catch (err) {
              const error = err as BusinessError;
              Logger.error(TAG, `StartAbility failed. code: ${error.code}, message: ${error.message}`);
            }
          })
          .margin({ bottom: $r('app.float.loading_size_sm') })
      }
      .onClick(() => handleReload?.())
      .width('100%')
      .height('100%')
      .padding($r('sys.float.padding_level8'))
      .backgroundColor($r('sys.color.background_secondary'))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}