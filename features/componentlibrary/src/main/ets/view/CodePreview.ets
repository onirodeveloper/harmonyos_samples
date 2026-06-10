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
import { uniformTypeDescriptor } from '@kit.ArkData';
import { CommonModifier, curves, window } from '@kit.ArkUI';
import { BusinessError, settings } from '@kit.BasicServicesKit';
import {
  hdsMaterial,
  HdsNavDestination,
  HdsNavigationMenuItemOptions,
  ScrollEffectType,
  TitleBarStyleOptions,
} from '@kit.UIDesignKit';
import {
  ActionName,
  CommonConstants,
  GlobalInfoModel,
  HdsUtil,
  InteractionTypeEnum,
  Logger,
  PasteboardUtil,
  ResourceUtil,
  ScreenOrientation,
  ShareUtil,
  StorageKey,
  TopNavigationView,
  TRACK_KEY,
  TrackEventType,
  TrackManager,
  TrackServiceData,
  WebNodeController,
  WebUtil,
  WIDTH_BREAKPOINTS,
  WindowUtil,
} from '@ohos/common';
import { CardTypeEnum } from '@ohos/commonbusiness';
import { CodePreviewComponent } from '../component/CodePreviewComponent';
import { CodePreviewJSUtil } from '../util/CodePreviewJSUtil';
import { BackPressParam, CodePreviewEventType, CodePreviewPageVM, PopParam } from '../viewmodel/CodePreviewPageVM';
import type { CodePreviewState } from '../viewmodel/CodePreviewState';
import { CodeViewParams } from '../viewmodel/ComponentDetailPageVM';
import { CustomToolBarItem } from '../model/CustomToolBarItem';

const TAG: string = '[CodePreview]';
const ORIENTATION_LOCK_ON: string = '0';

@Component
export struct CodePreview {
  @StorageLink(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE) ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  private viewModel?: CodePreviewPageVM;
  private beginScreenOrientation: string = ScreenOrientation.PORTRAIT;
  private beginBreakpoint: WidthBreakpoint = this.globalInfoModel.widthBreakpoint;
  private beginOrientationLockState?: string;
  private code: string = '';
  private context: Context = this.getUIContext().getHostContext() as Context;
  private uiContext: UIContext = this.getUIContext();
  public contentType: CardTypeEnum = CardTypeEnum.COMPONENT;
  private windowClass: window.Window | undefined = undefined;
  private colorMode: ConfigurationConstant.ColorMode = this.systemColorMode;
  private isSupportMaterial: boolean = HdsUtil.isSupportNewMaterialApi();
  private currentPathStack: NavPathStack = new NavPathStack();
  @State nodeContainerPaddingLeft: ResourceStr = $r('sys.float.padding_level12');
  @State webNodeController?: WebNodeController = undefined;
  @State isFocus: boolean = false;
  @State isOrientationLockChange: boolean = false;
  @State codePreviewState?: CodePreviewState = this.viewModel?.getState();
  @State componentName: string = '';
  @StorageLink('isDarkMode') isDarkMode: boolean =
    (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  @State screenOrientation: string = (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ||
    this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL) ? ScreenOrientation.LANDSCAPE :
    ScreenOrientation.PORTRAIT;
  @State isFloatWindowType: boolean = false;
  @State titleBarStyle: TitleBarStyleOptions = {
    scrollEffectOpts: {
      scrollEffectType: ScrollEffectType.COMMON_BLUR,
      enableScrollEffect: true,
    },
  };
  private navCommonModifier?: CommonModifier = new CommonModifier()
    .onFocus(() => {
      this.isFocus = true;
    })
    .onBlur(() => {
      this.isFocus = false;
    });
  private toolbarOptions: NavigationToolbarOptions = {
    backgroundColor: Color.Transparent,
    barStyle: BarStyle.STACK,
  };
  private topMenuItems: CustomToolBarItem[] = [
    {
      symbolIcon: $r('sys.symbol.share'),
      value: '',
      actionValue: '',
      actionName: ActionName.CODE_SHARE,
      action: () => {
        this.handleShare();
      },
    }
  ];
  private hdsMenuItems: HdsNavigationMenuItemOptions[] = [
    {
      content: {
        icon: $r('sys.symbol.share'),
        isEnabled: true,
        action: () => {
          this.reportTrackData(ActionName.CODE_SHARE);
          this.handleShare();
        },
      },
    },
    {
      content: {
        icon: $r('sys.symbol.plus_square_on_square'),
        isEnabled: true,
        action: () => {
          this.reportTrackData(ActionName.CODE_COPY);
          PasteboardUtil.copyText(this.code);
        },
      },
    }]
  @State toolBarItems: CustomToolBarItem[] = [
    {
      symbolIcon: AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? $r('sys.symbol.plus_square_on_square') :
        $r('sys.symbol.plus_square_on_square_fill'),
      value: $r('app.string.copy'),
      actionValue: $r('app.string.copy'),
      actionName: ActionName.CODE_COPY,
      action: () => {
        PasteboardUtil.copyText(this.code);
      },
    },
    {
      symbolIcon: $r('sys.symbol.sun_max_fill'),
      activeSymbolIcon: $r('sys.symbol.moon_fill'),
      value: $r('app.string.light_mode'),
      actionValue: $r('app.string.dark_mode'),
      status: this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? ToolbarItemStatus.NORMAL :
        ToolbarItemStatus.ACTIVE,
      actionName: ActionName.UNKNOWN,
      action: () => {
        this.changeColorMode();
      },
    },
    {
      symbolIcon: $r('sys.symbol.screen_rotation'),
      value: $r('app.string.portrait_screen'),
      actionValue: $r('app.string.landscape_screen'),
      status: this.screenOrientation === ScreenOrientation.LANDSCAPE ? ToolbarItemStatus.NORMAL :
        ToolbarItemStatus.ACTIVE,
      actionName: ActionName.UNKNOWN,
      action: () => {
        this.changeScreenOrientation();
      },
    }
  ];
  private windowSizeCallback: Callback<window.Size> = (size) => {
    if (size.width > size.height) {
      this.screenOrientation = ScreenOrientation.LANDSCAPE;
      if (!this.codePreviewState?.isBackPressed) {
        const showLandscapeMethod: string =
          this.isFloatWindowType ? 'showLandscapeFloatView(%param)' : 'showLandscapeView(%param)';
        const params: string = JSON.stringify(WIDTH_BREAKPOINTS[this.beginBreakpoint]);
        CodePreviewJSUtil.codeViewRunJS(showLandscapeMethod, params);
        if (this.beginBreakpoint === WidthBreakpoint.WIDTH_SM) {
          this.nodeContainerPaddingLeft = $r('sys.float.padding_level24');
        }
      }
    } else {
      this.screenOrientation = ScreenOrientation.PORTRAIT;
      if (!this.codePreviewState?.isBackPressed) {
        const showPortraitMethod: string = 'showPortraitView()';
        CodePreviewJSUtil.codeViewRunJS(showPortraitMethod);
        this.nodeContainerPaddingLeft = $r('sys.float.padding_level12');
      }
    }
    this.toolBarItems[2].status = this.screenOrientation === ScreenOrientation.LANDSCAPE ? ToolbarItemStatus.NORMAL :
      ToolbarItemStatus.ACTIVE;
  };

  handleColorModeChange() {
    if (this.colorMode !== this.systemColorMode) {
      this.changeColorMode();
    }
  }

  changeColorMode() {
    if (this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      this.isDarkMode = true;
      this.toolBarItems[1].status = ToolbarItemStatus.NORMAL;
    } else {
      this.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      this.isDarkMode = false;
      this.toolBarItems[1].status = ToolbarItemStatus.ACTIVE;
    }
    WindowUtil.updateStatusBarColor(this.isDarkMode);
  }

  reportTrackData(actionName: ActionName): void {
    const trackData: TrackServiceData = {
      eventType: TrackEventType.CLICK,
      interactionContent: this.componentName,
      interactionType: InteractionTypeEnum.COMPONENT,
      actionName,
    } as TrackServiceData;
    TrackManager.getInstance().reportData(trackData);
  }

  private changeScreenOrientation(): void {
    if (this.screenOrientation === ScreenOrientation.PORTRAIT) {
      this.toolBarItems[2].status = ToolbarItemStatus.NORMAL;
      this.screenOrientation = ScreenOrientation.LANDSCAPE;
      WindowUtil.enableFloatWindowRotate();
      WindowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE, () => {
        this.updateStatusBar();
      });
    } else {
      this.toolBarItems[2].status = ToolbarItemStatus.ACTIVE;
      this.screenOrientation = ScreenOrientation.PORTRAIT;
      WindowUtil.disableFloatWindowRotate();
      WindowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT, () => {
        this.updateStatusBar();
      });
    }
  }

  updateStatusBar() {
    setTimeout(() => {
      WindowUtil.updateStatusBarColor(this.isDarkMode);
    }, 500);
  }

  onBackPage(): boolean {
    if (!this.codePreviewState?.isBackPressed) {
      this.viewModel?.sendEvent<BackPressParam>({
        type: CodePreviewEventType.CHANGE_BACK_PRESSED,
        param: { backPressed: true }
      });
      WindowUtil.updateStatusBarColor(this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      this.javascriptRun();
      WebUtil.downPage(WebUtil.getComponentCodeUrl());
      this.webNodeController = undefined;
      this.resetScreenOrientation();
      this.preFinishAnimation();
      this.uiContext?.animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 38) }, () => {
        this.viewModel?.sendEvent<PopParam>({
          type: CodePreviewEventType.POP,
          param: { animation: false, pathStack: this.currentPathStack }
        });
      });
    }
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
    this.isDarkMode = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    this.viewModel = CodePreviewPageVM.getInstance();
    this.initOrientationState();
    this.viewModel.sendEvent<null>({ type: CodePreviewEventType.INIT, param: null });
    this.handleDeviceOrientation();
    if (this.isSupportMaterial) {
      this.titleBarStyle = {
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
            ScrollEffectType.COMMON_BLUR,
        },
      };
    }
    try {
      window.getLastWindow(this.context).then((windowClass: window.Window) => {
        if (windowClass === undefined) {
          Logger.error(TAG, `MainWindowClass is undefined`);
          return;
        }
        this.windowClass = windowClass;
        this.windowClass.on('windowSizeChange', this.windowSizeCallback);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `getLastWindow failed. cause ${error.message}`);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG,
        `Failed to register windowSizeChange. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  aboutToDisappear(): void {
    this.isDarkMode = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    WindowUtil.setMainWindowOrientation(window.Orientation.UNSPECIFIED);
    this.unregisterWindowChange();
    try {
      this.windowClass?.off('windowSizeChange', this.windowSizeCallback);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG,
        `Failed to unregister windowSizeChange. Cause code: ${err.code}, message: ${err.message}`);
    }
    if (canIUse('SystemCapability.Applications.Settings.Core')) {
      settings.unregisterKeyObserver(this.context,
        settings.general.ACCELEROMETER_ROTATION_STATUS,
        settings.domainName.DEVICE_SHARED);
    }
  }

  handleDeviceOrientation() {
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        // Retrieve the floating window status
        this.windowClass!.on('windowStatusChange', (windowStatusType) => {
          if (windowStatusType === window.WindowStatusType.FLOATING) {
            this.isFloatWindowType = true;
            // For the first time, directly set it to vertical floating mode.
            this.screenOrientation = ScreenOrientation.PORTRAIT;
          } else {
            this.isFloatWindowType = false;
            // if it is in fullscreen mode, restore it based on the device.
            // Restore the tablet to landscape mode.
            if (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM) {
              this.screenOrientation = ScreenOrientation.PORTRAIT;
            }
          }
        });
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG,
        `Failed to register callback. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  unregisterWindowChange() {
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        // Retrieve the floating window status
        this.windowClass!.off('windowStatusChange');
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG,
        `Failed to unregister callback. Cause code: ${err.code}, message: ${err.message}`);
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

  handleShare(): void {
    const shareDescription = ResourceUtil.getResourceString(this.context, $r('app.string.share_description'));
    ShareUtil.shareData({
      utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
      content: this.code,
      title: this.componentName,
      description: shareDescription
    });
  }

  handleOnReady(ctx: NavDestinationContext): void {
    this.currentPathStack = ctx.pathStack;
    const params: CodeViewParams = ctx.pathInfo.param as CodeViewParams;
    this.code = params.code as string;
    this.componentName = params.componentName as string;
    this.webNodeController = WebUtil.getWebNode(WebUtil.getComponentCodeUrl()) as WebNodeController;
    this.preFinishAnimation = params.preFinishAnimation as () => void;
    this.codePreviewState = this.viewModel!.getState();
    this.viewModel?.sendEvent<BackPressParam>({
      type: CodePreviewEventType.CHANGE_BACK_PRESSED,
      param: { backPressed: false }
    });
  }

  @Builder
  TopNavigationMenu() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
      Row({ space: CommonConstants.SPACE_8 }) {
        ForEach(this.topMenuItems.concat(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
          this.toolBarItems[0] : []), (item: CustomToolBarItem, _index: number) => {
          Button() {
            SymbolGlyph(item.symbolIcon)
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r('sys.color.icon_primary')])
              .opacity(this.isFocus ? 1 : 0.4)
          }
          .customProperty(TRACK_KEY, {
            interactionContent: this.componentName,
            interactionType: InteractionTypeEnum.COMPONENT,
            actionName: item.actionName,
          } as TrackServiceData)
          .height($r('app.float.code_preview_top_navigation_height'))
          .aspectRatio(1)
          .hoverEffect(HoverEffect.Highlight)
          .backgroundColor(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? Color.Transparent :
            $r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            item.action?.();
          })
        }, (index: number) => index.toString())
      }
      .margin({
        right: AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? $r('app.float.code_preview_icon_margin') : 0
      })
    }
  }

  @Builder
  TopTitleViewBuilder() {
    TopNavigationView({
      topNavigationData: {
        isFullScreen: true,
        isBlur: true,
        title: this.componentName,
        onBackClick: () => this.onBackPage?.(),
      },
      menuView: () => {
        this.TopNavigationMenu();
      }
    })
      .translate({ y: this.codePreviewState?.topTranslateY })
      .position({ x: 0, y: 0 })
      .opacity(this.codePreviewState?.navigationOpacity)
  }

  @Builder
  PreviewContentBuilder() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
      Stack({ alignContent: Alignment.TopStart }) {
        CodePreviewComponent({
          webNodeController: this.webNodeController,
          code: this.code,
          componentName: this.componentName,
          pageContainer: true,
          isDarkMode: this.isDarkMode,
          nodeContainerPaddingLeft: this.nodeContainerPaddingLeft,
          nodeContainerPaddingTop: this.globalInfoModel.statusBarHeight,
        })
          .onClick(() => {
            this.viewModel?.sendEvent<null>({ type: CodePreviewEventType.HANDLE_PAGE_CLICK, param: null });
          })
        if (!this.isSupportMaterial) {
          this.TopTitleViewBuilder()
        }
      }
      .geometryTransition(CommonConstants.CODE_PREVIEW_GEOMETRY_ID)
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  ToolBarBuilder() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
      Row() {
        ForEach(this.toolBarItems, (item: CustomToolBarItem) => {
          CustomToolItemComponent({
            item,
          })
            .customProperty(TRACK_KEY, {
              interactionContent: this.componentName,
              interactionType: InteractionTypeEnum.COMPONENT,
              actionName: item.actionName,
            } as TrackServiceData)
        }, (_item: CustomToolBarItem, index: number) => index.toString())
      }
      .width('100%')
      .height(CommonConstants.TOOL_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight)
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor(Color.Transparent)
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
      .padding({ bottom: this.globalInfoModel.naviIndicatorHeight > 0 ? this.globalInfoModel.naviIndicatorHeight :
        $r('sys.float.padding_level8') })
      .margin({
        bottom: -(this.codePreviewState?.bottomTranslateY ?? 0) * 2
      })
    }
  }

  build() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
      if (this.isSupportMaterial) {
        HdsNavDestination() {
          Stack({ alignContent: Alignment.Bottom }) {
            this.PreviewContentBuilder()
            if (!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
              this.ToolBarBuilder()
            }
          }
        }
        .withTheme({ enableThemeColorMode: true })
        .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
        .hideTitleBar(this.codePreviewState?.topTranslateY != 0, true)
        .titleBar({
          style: this.titleBarStyle,
          content: {
            title: { mainTitle: this.componentName },
            menu: {
              value: AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? this.hdsMenuItems :
                this.hdsMenuItems.slice(0, 1)
            },
          }
        })
        .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
        .bindToScrollable([WebUtil.getWebScroller(WebUtil.getComponentCodeUrl()) as Scroller])
        .attributeModifier(this.navCommonModifier)
        .onBackPressed(() => {
          return this.onBackPage();
        })
      } else {
        HdsNavDestination() {
          Stack({ alignContent: Alignment.Bottom }) {
            this.PreviewContentBuilder()
            if (!AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT)) {
              this.ToolBarBuilder()
            }
          }
        }
        .hideBackButton(false)
        .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
        .hideTitleBar(true)
        .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
        .bindToScrollable([WebUtil.getWebScroller(WebUtil.getComponentCodeUrl()) as Scroller])
        .attributeModifier(this.navCommonModifier)
        .onBackPressed(() => {
          return this.onBackPage();
        })
      }
    }
  }

  private preFinishAnimation: () => void = () => {
  };
}

@Builder
export function CodePreviewBuilder() {
  CodePreview()
}

@Component
struct CustomToolItemComponent {
  @Prop item: CustomToolBarItem;

  build() {
    Column() {
      SymbolGlyph((this.item.activeSymbolIcon && this.item.status === ToolbarItemStatus.ACTIVE) ?
        this.item.activeSymbolIcon : this.item.symbolIcon)
        .fontSize($r('sys.float.Title_M'))
        .fontColor([$r('sys.color.icon_secondary')])
      Text((this.item.actionValue && this.item.status === ToolbarItemStatus.ACTIVE) ? this.item.actionValue :
        this.item.value)
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: $r('sys.float.padding_level2') })
    }
    .height('100%')
    .width($r('app.float.tip_button_width'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.item.status =
        (this.item.status === ToolbarItemStatus.ACTIVE) ? ToolbarItemStatus.NORMAL : ToolbarItemStatus.ACTIVE
      this.item.action?.();
    })
  }
}