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

export enum LinkType {
  TYPE_GALLERY = '应用市场',
  TYPE_MAP = '地图',
  TYPE_SETTINGS = '设置',
  TYPE_DAIL = '拨号',
}

export const typeMapData: Map<string, LinkType> = new Map([
  ['Default', LinkType.TYPE_GALLERY],
  ['应用市场', LinkType.TYPE_GALLERY],
  ['地图', LinkType.TYPE_MAP],
  ['设置', LinkType.TYPE_SETTINGS],
  ['拨号', LinkType.TYPE_DAIL],
]);

export const typeImportCodeMapData: Map<LinkType, string> = new Map([
  [LinkType.TYPE_GALLERY, `import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';`],
  [LinkType.TYPE_MAP, `import { common } from '@kit.AbilityKit';`],
  [LinkType.TYPE_SETTINGS, `import { common, Want } from '@kit.AbilityKit';`],
  [LinkType.TYPE_DAIL, `import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';`],
]);

export const typeResourcesMapData: Map<LinkType, ResourceStr> = new Map([
  [LinkType.TYPE_GALLERY, $r('app.string.pull_up_gallery')],
  [LinkType.TYPE_MAP, $r('app.string.pull_up_map')],
  [LinkType.TYPE_SETTINGS, $r('app.string.pull_up_settings')],
  [LinkType.TYPE_DAIL, $r('app.string.pull_up_dail')],
]);

export const wantParam: Record<string, Object> = {
  'sceneType': 1,
  'destinationLatitude': 40.00,
  'destinationLongitude': 116.19,
  'destinationName': '北京市香山公园',
  'originName': '华为北研所',
  'originLatitude': 40.06,
  'originLongitude': 116.18,
  'vehicleType': 0,
};

export const wantParamCode: string = `{
              'sceneType': 1,
              'destinationLatitude': 40.00,
              'destinationLongitude': 116.19,
              'destinationName': '北京市香山公园',
              'originName': '华为北研所',
              'originLatitude': 40.06,
              'originLongitude': 116.18,
              'vehicleType': 0,
            }`;

export const linkCodeGallery: string = `const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
            const link: string = '%s';
            context.openLink(link, { appLinkingOnly: false })
              .then(() => {
                console.log('OpenLink success.');
              })
              .catch((error: BusinessError) => {
                console.log(\`Openlink failed. Code: \${error.code}, message is \${error.message}\`);
              });`;

export const linkCodeMap: string = `const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
            const abilityStartCallback: common.AbilityStartCallback = {
              onError: (code: number, name: string, message: string) => {
                console.log('Fail start ability');
              },
              onResult: (result) => {
                console.log('Success in start ability.');
              }
            }
            try {
              context.startAbilityByType('navigation',${wantParamCode}, abilityStartCallback);
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              console.error(\`StartAbilityByType error, the code is \${error.code}, the message is \${error.message}\`);
            }`

export const linkCodeSettings: string = `const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
          const want: Want = {
            bundleName: 'com.huawei.hmos.settings',
            abilityName: 'com.huawei.hmos.settings.MainAbility',
            uri: '',
          };
          try {
            context.startAbility(want);;
          } catch (err) {
            const error: BusinessError = err as BusinessError;
            console.error(\`StartAbility error, the code is \${error.code}, the message is \${error.message}\`);
          }`

export const linkCodeDail: string = `call.makeCall('', (err: BusinessError) => {
            if (err) {
              console.log('MakeCall fail');
            } else {
              console.log('MakeCall success');
            }
          });`;

export const typeInvokeCodeMapData: Map<LinkType, string> = new Map([
  [LinkType.TYPE_GALLERY, linkCodeGallery],
  [LinkType.TYPE_MAP, linkCodeMap],
  [LinkType.TYPE_SETTINGS, linkCodeSettings],
  [LinkType.TYPE_DAIL, linkCodeDail],
]);