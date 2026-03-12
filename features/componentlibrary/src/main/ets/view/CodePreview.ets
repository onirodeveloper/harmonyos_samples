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
import { curves, window } from '@kit.ArkUI';
import { BusinessError, settings } from '@kit.BasicServicesKit';
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import {
  CommonConstants,
  GlobalInfoModel,
  Logger,
  ScreenOrientation,
  StorageKey,
  VersionUtil,
  WebNodeController,
  WebUtil,
  WindowUtil,
} from '@ohos/common';
import { CodePreviewComponent } from '../component/CodePreviewComponent';
import { CodePreviewJSUtil } from '../util/CodePreviewJSUtil';
import { CodePreviewEvent, CodePreviewPageVM } from '../viewmodel/CodePreviewPageVM';
import type { CodePreviewState } from '../viewmodel/CodePreviewState';
import { CodeViewParams } from '../viewmodel/ComponentDetailPageVM';

const TAG: string = '[CodePreview]';
const ORIENTATION_LOCK_ON: string = '0';

@Component
export struct CodePreview {
  @StorageLink(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  @State webNodeController?: WebNodeController = undefined;
  @State isFocus: boolean = false;
  @State isBack: boolean = false;
  @State isOrientationLockChange: boolean = false;
  private viewModel?: CodePreviewPageVM;
  @State codePreviewState?: CodePreviewState = this.viewModel?.getState();
  private beginScreenOrientation: string = ScreenOrientation.PORTRAIT;
  private beginBreakpoint: WidthBreakpoint = this.globalInfoModel.widthBreakpoint;
  private beginOrientationLockState?: string;
  private code: string = '';
  private componentName: string = '';
  private context: Context = this.getUIContext().getHostContext() as Context;
  private uiContext: UIContext = this.getUIContext();

  onBackPage(): boolean {
    this.isBack = true;
    WindowUtil.updateStatusBarColor(this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    this.javascriptRun();
    WebUtil.downPage(WebUtil.getComponentCodeUrl());
    this.webNodeController = undefined;
    this.resetScreenOrientation();
    this.preFinishAnimation();
    this.uiContext?.animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 38) }, () => {
      this.viewModel?.pop(false);
    });
    return true;
  }

  javascriptRun(): void {
    const toSmallScreenMethod: string = 'toSmallScreen()';
    const changeColorModeMethod: string = 'changeColorMode(%param)';
    const changeColorModeParams: string = JSON.stringify(this.systemColorMode);
    CodePreviewJSUtil.codeViewRunJS(toSmallScreenMethod);
    CodePreviewJSUtil.codeViewRunJS(changeColorModeMethod, changeColorModeParams);
  }

  aboutToAppear(): void {
    this.viewModel = CodePreviewPageVM.getInstance();
    this.initOrientationState();
    this.viewModel.sendEvent(CodePreviewEvent.INIT);
  }

  aboutToDisappear(): void {
    WindowUtil.setMainWindowOrientation(window.Orientation.UNSPECIFIED);
    if (canIUse('SystemCapability.Applications.Settings.Core')) {
      settings.unregisterKeyObserver(this.context,
        settings.general.ACCELEROMETER_ROTATION_STATUS,
        settings.domainName.DEVICE_SHARED);
    }
  }

  private initOrientationState(): void {
    if (this.globalInfoModel.deviceWidth > this.globalInfoModel.deviceHeight) {
      this.beginScreenOrientation = ScreenOrientation.LANDSCAPE;
    } else {
      this.beginScreenOrientation = ScreenOrientation.PORTRAIT;
    }
    if (canIUse('SystemCapability.Applications.Settings.Core')) {
      this.beginOrientationLockState =
        settings.getValueSync(this.context, settings.general.ACCELEROMETER_ROTATION_STATUS,
          settings.domainName.DEVICE_SHARED);
      this.registerKeyObserver();
    }
  }

  private registerKeyObserver(): boolean {
    if (canIUse('SystemCapability.Applications.Settings.Core')) {
      try {
        return settings.registerKeyObserver(this.context, settings.general.ACCELEROMETER_ROTATION_STATUS,
          settings.domainName.DEVICE_SHARED, () => {
            this.isOrientationLockChange = true;
          });
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG,
          `RegisterKeyObserver ${settings.general.ACCELEROMETER_ROTATION_STATUS} error: ${error.code}, ${error.message}`);
        return false;
      }
    }
    return false;
  }

  private resetScreenOrientation(): void {
    if (!this.isOrientationLockChange && this.beginOrientationLockState === ORIENTATION_LOCK_ON) {
      if (this.beginBreakpoint === WidthBreakpoint.WIDTH_LG || this.beginBreakpoint === WidthBreakpoint.WIDTH_MD) {
        if (this.beginScreenOrientation === ScreenOrientation.LANDSCAPE) {
          WindowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE);
        } else {
          WindowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
        }
      }
    }
  }

  handleOnReady(ctx: NavDestinationContext) {
    const params: CodeViewParams = ctx.pathInfo.param as CodeViewParams;
    this.code = params.code as string;
    this.componentName = params.componentName as string;
    this.webNodeController = WebUtil.getWebNode(WebUtil.getComponentCodeUrl()) as WebNodeController;
    this.preFinishAnimation = params.preFinishAnimation as () => void;
    this.codePreviewState = this.viewModel!.getState();
  }

  @Builder
  PreviewContentBuilder() {
    Column() {
      CodePreviewComponent({
        onBackPage: () => {
          this.onBackPage();
        },
        webNodeController: this.webNodeController,
        code: this.code,
        componentName: this.componentName,
        pageContainer: true,
        topTranslateY: this.codePreviewState?.topTranslateY,
        bottomTranslateY: this.codePreviewState?.bottomTranslateY,
        navigationOpacity: this.codePreviewState?.navigationOpacity,
        isFocus: this.isFocus,
        isBack: this.isBack,
      })
    }
    .geometryTransition(CommonConstants.CODE_PREVIEW_GEOMETRY_ID)
    .width('100%')
    .height('100%')
  }

  build() {
    if (VersionUtil.canUseHds()) {
      HdsNavDestination() {
        this.PreviewContentBuilder()
      }
      .hideTitleBar(true)
      .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
      .onShown(() => {
        this.isBack = false;
      })
      .onFocus(() => {
        this.isFocus = true;
      })
      .onBlur(() => {
        this.isFocus = false;
      })
      .onBackPressed(() => {
        return this.onBackPage();
      })
    } else {
      NavDestination() {
        this.PreviewContentBuilder()
      }
      .width('100%')
      .height('100%')
      .hideTitleBar(true)
      .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
      .onFocus(() => {
        this.isFocus = true;
      })
      .onBlur(() => {
        this.isFocus = false;
      })
      .onShown(() => {
        this.isBack = false;
      })
      .onBackPressed(() => {
        return this.onBackPage();
      })
    }
  }

  private preFinishAnimation: () => void = () => {
  };
}

@Builder
export function CodePreviewBuilder() {
  CodePreview()
}