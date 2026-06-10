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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { HdsNavigation } from '@kit.UIDesignKit';
import { SplashView } from '@ohos/abilitycommon';
import { BundleInfoData, Logger, PageContext, ResourceUtil, StorageKey, WindowUtil, } from '@ohos/common';

const TAG: string = '[SplashPage]';

@Entry
@Component
struct SplashPage {
  context: Context = this.getUIContext().getHostContext() as Context;
  @StorageProp(StorageKey.BUNDLE_INFO) @Watch('updateIcon') bundleInfo?: BundleInfoData =
    AppStorage.get(StorageKey.BUNDLE_INFO);
  @StorageLink(StorageKey.HOME_PAGE_CONTEXT) pageContext: PageContext =
    AppStorage.get<PageContext>(StorageKey.HOME_PAGE_CONTEXT) ?? new PageContext();
  @StorageProp(StorageKey.COLOR_MODE) systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  private appPathInfo: NavPathStack = this.pageContext?.navPathStack;
  @Provide('appIconDescriptor') drawableDescriptor?: DrawableDescriptor = undefined;

  aboutToAppear(): void {
    this.updateIcon();
  }

  onPageShow(): void {
    Logger.info(TAG, `SplashPage showing.`)
  }

  onPageHide() {
    Logger.info(TAG, 'onPageHide');
    const isSystemDark: boolean =
      AppStorage.get(StorageKey.COLOR_MODE) === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    WindowUtil.updateStatusBarColor(isSystemDark);
  }

  updateIcon() {
    this.drawableDescriptor =
      ResourceUtil.getDrawableDescriptor(this.context, this.bundleInfo?.iconResource?.id);
  }

  build() {
    HdsNavigation(this.appPathInfo) {
      SplashView()
    }
    .hideTitleBar(true)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
  }
}