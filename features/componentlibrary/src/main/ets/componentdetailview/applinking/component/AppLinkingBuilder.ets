/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apach License, Version 2.0 (the "License");
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
import { call } from '@kit.TelephonyKit';
import { ConfigMapKey, Logger, ResourceUtil } from '@ohos/common';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { AppLinkingDescriptor } from '../viewmodel/AppLinkingDescriptor';
import { LinkType, typeResourcesMapData, wantParam } from '../entity/AppLinkingAttributeMapping';

const TAG: string = '[AppLinkingComponent]';

@Builder
export function AppLinkingBuilder($$: DescriptorWrapper) {
  AppLinkingComponent({ appLinkingDescriptor: $$.descriptor as AppLinkingDescriptor })
}

@Component
struct AppLinkingComponent {
  @Prop appLinkingDescriptor: AppLinkingDescriptor;
  private galleryUrl: string = '';

  build() {
    Column() {
      Button($r('app.string.pull_up_page', typeResourcesMapData.get(this.appLinkingDescriptor.type)))
        .backgroundColor($r('sys.color.background_secondary'))
        .height($r('app.float.button_height_normal'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          if (this.appLinkingDescriptor.type === LinkType.TYPE_GALLERY) {
            this.jumpToGallery();
          } else if (this.appLinkingDescriptor.type === LinkType.TYPE_MAP) {
            this.jumpToMap();
          } else if (this.appLinkingDescriptor.type === LinkType.TYPE_SETTINGS) {
            this.jumpToSettings();
          } else if (this.appLinkingDescriptor.type === LinkType.TYPE_DAIL) {
            this.jumpToDial();
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  jumpToGallery(): void {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    if (!this.galleryUrl) {
      this.galleryUrl = ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.GALLERY_URL);
    }
    try {
      context.openLink(this.galleryUrl, { appLinkingOnly: false })
        .then(() => {
          Logger.info(TAG, 'OpenLink success.');
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `Openlink failed. Code: ${error.code}, message is ${error.message}`);
        });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Openlink failed., error code: ${err.code}, message: ${err.message}.`);
    }
  }

  jumpToMap(): void {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const abilityStartCallback: common.AbilityStartCallback = {
      onError: (code: number, name: string, message: string) => {
        Logger.error(TAG, `Fail start ability, name is ${name}, code is ${code}, message is ${message}`);
      },
      onResult: (result) => {
        Logger.debug(TAG, `Success in start ability, result is ${JSON.stringify(result)}`);
      }
    }
    try {
      context.startAbilityByType('navigation', wantParam, abilityStartCallback);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `StartAbilityByType error, the code is ${error.code}, the message is ${error.message}`);
    }
  }

  jumpToSettings(): void {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: '',
    };
    try {
      context.startAbility(want);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `StartAbility error, the code is ${error.code}, the message is ${error.message}`);
    }
  }

  jumpToDial(): void {
    // Check whether support call function
    let isSupport = call.hasVoiceCapability();
    if (isSupport) {
      if (canIUse('SystemCapability.Applications.Contacts')) {
        call.makeCall('', (err: BusinessError) => {
          if (err) {
            Logger.error(TAG, `MakeCall fail, error code ${err.code}, message: ${err.message}`);
          } else {
            Logger.info(TAG, `MakeCall success`);
          }
        });
      }
    } else {
      AlertDialog.show({
        title: '',
        message: $r('app.string.not_support_dial'),
        primaryButton: {
          value: $r('app.string.sure'),
          action: () => {
            Logger.info(TAG, 'The device does not support dial-up.');
          }
        }
      });
    }
  }
}