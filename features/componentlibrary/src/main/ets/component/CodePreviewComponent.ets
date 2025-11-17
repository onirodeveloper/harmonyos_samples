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

import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { window } from '@kit.ArkUI';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { systemShare } from '@kit.ShareKit';
import { GlobalInfoModel, TopNavigationView, VersionUtil } from '@ohos/common';
import {
  CommonConstants,
  Logger,
  ResourceUtil,
  ScreenOrientation,
  StorageKey,
  Toast,
  WebNodeController,
  WIDTH_BREAKPOINTS,
  WindowUtil,
} from '@ohos/common';
import { CodePreviewJSUtil } from '../util/CodePreviewJSUtil';

const TAG: string = '[CodePreviewComponent]';

@Component
export struct CodePreviewComponent {
  @StorageProp(StorageKey.COLOR_MODE) @Watch('handleColorModeChange') systemColorMode: ConfigurationConstant.ColorMode =
    AppStorage.get(StorageKey.COLOR_MODE)!;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;
  @Prop @Watch('flushCode') code: string = '';
  @Prop pageContainer: boolean = false;
  @Prop isFocus: boolean = false;
  @Prop isBack: boolean = false;
  @Prop topTranslateY: number = 0;
  @Prop bottomTranslateY: number = 0;
  @Prop navigationOpacity: number = 1;
  colorMode: ConfigurationConstant.ColorMode = this.systemColorMode;
  @State isDarkMode: boolean = (this.systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  @State screenOrientation: string = this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_LG ?
    ScreenOrientation.LANDSCAPE : ScreenOrientation.PORTRAIT;
  @State isFloatWindowType: boolean = false;
  @State isHover: boolean = false;
  @Link webNodeController: WebNodeController;
  onBackPage?: () => void;
  public pushPage?: (value: string) => void;
  public componentName: string = '';
  private windowClass: window.Window | undefined = undefined;
  private topIconItems: ItemData[] = [
    new ItemData(
      {
        iconResource: $r('sys.symbol.arrow_up_left_and_arrow_down_right'),
      } as ResourceInterface,
      () => {
        this.pushPage?.(this.code);
      }, 0)
  ];
  private shareItem: ItemData =
    new ItemData(
      {
        iconResource: $r('sys.symbol.share'),
      } as ResourceInterface,
      () => {
        this.handleShare();
      }, 5);
  private bottomIconItems: ItemData[] = [
    new ItemData(
      {
        iconResource: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
          $r('sys.symbol.plus_square_on_square') : $r('sys.symbol.plus_square_on_square_fill'),
        iconTitle: $r('app.string.copy')
      } as ResourceInterface,
      () => {
        this.copyText(this.code);
      }, 0),
    new ItemData(
      {
        iconResource: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
          $r('sys.symbol.sun_max') : $r('sys.symbol.sun_max_fill'),
        iconTitle: $r('app.string.dark_mode'),
      } as ResourceInterface,
      () => {
        this.changeColorMode();
      }, 1,
      {
        iconResource: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
          $r('sys.symbol.moon') : $r('sys.symbol.moon_fill'),
        iconTitle: $r('app.string.light_mode'),
      } as ResourceInterface),
    new ItemData(
      {
        iconResource: $r('sys.symbol.screen_rotation'),
        iconTitle: this.screenOrientation === ScreenOrientation.PORTRAIT ? $r('app.string.landscape_screen') :
          $r('app.string.portrait_screen')
      } as ResourceInterface,
      () => {
        this.changeScreenOrientation();
      }, 2)
  ];
  private topMenuList: ItemData[] = this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
    [this.shareItem, ...this.bottomIconItems.slice(0, 1)] : [this.shareItem];
  private beginBreakpoint: WidthBreakpoint = this.globalInfoModel.widthBreakpoint;
  private windowSizeCallback: Callback<window.Size> = (size) => {
    if (size.width > size.height) {
      this.screenOrientation = ScreenOrientation.LANDSCAPE;
      if (this.pageContainer && !this.isBack) {
        const showLandscapeMethod: string =
          this.isFloatWindowType ? 'showLandscapeFloatView(%param)' : 'showLandscapeView(%param)';
        const params: string = WIDTH_BREAKPOINTS[this.beginBreakpoint];
        CodePreviewJSUtil.codeViewRunJS(showLandscapeMethod, params);
      }
    } else {
      this.screenOrientation = ScreenOrientation.PORTRAIT;
      if (this.pageContainer && !this.isBack) {
        const showPortraitMethod: string = 'showPortraitView()';
        CodePreviewJSUtil.codeViewRunJS(showPortraitMethod);
      }
    }
    this.changeBottomIconData();
  };

  aboutToAppear?(): void {
    if (this.pageContainer) {
      try {
        window.getLastWindow(this.getUIContext().getHostContext()).then((windowClass: window.Window) => {
          if (windowClass === undefined) {
            Logger.error(TAG, `MainWindowClass is undefined`);
            return;
          }
          this.windowClass = windowClass;
          this.windowClass.on('windowSizeChange', this.windowSizeCallback);
        });
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG,
          `Failed to register windowSizeChange. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
  }

  aboutToDisappear(): void {
    if (this.pageContainer) {
      try {
        this.windowClass?.off('windowSizeChange', this.windowSizeCallback);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG,
          `Failed to unregister windowSizeChange. Cause code: ${err.code}, message: ${err.message}`);
      }
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
        `Failed to unregister callback. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  flushCode() {
    const codeToHtmlMethod: string = 'codeToHtml(%param)';
    const params: string = JSON.stringify(this.code);
    CodePreviewJSUtil.codeViewRunJS(codeToHtmlMethod, params);
  }

  handleColorModeChange() {
    if (this.colorMode !== this.systemColorMode) {
      this.changeColorMode();
    }
  }

  changeColorMode() {
    if (this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      this.isDarkMode = true;
    } else {
      this.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      this.isDarkMode = false;
    }
    WindowUtil.updateStatusBarColor(this.isDarkMode);
    const changeColorModeMethod: string = 'changeColorMode(%param)';
    const params: string = JSON.stringify(this.colorMode);
    CodePreviewJSUtil.codeViewRunJS(changeColorModeMethod, params);
  }

  private changeScreenOrientation(): void {
    if (this.screenOrientation === ScreenOrientation.PORTRAIT) {
      WindowUtil.enableFloatWindowRotate();
      WindowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE, () => {
        this.updateStatusBar();
      });
    } else {
      WindowUtil.disableFloatWindowRotate();
      WindowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT, () => {
        this.updateStatusBar();
      });
    }
  }

  updateStatusBar() {
    if (VersionUtil.canUseHds()) {
      setTimeout(() => {
        WindowUtil.updateStatusBarColor(this.isDarkMode);
      }, 500);
    }
  }

  private changeBottomIconData(): void {
    if (this.bottomIconItems[2]) {
      this.bottomIconItems[2].lightMode = {
        iconResource: $r('sys.symbol.screen_rotation'),
        iconTitle: this.screenOrientation === ScreenOrientation.PORTRAIT ? $r('app.string.landscape_screen') :
          $r('app.string.portrait_screen'),
      };
      this.bottomIconItems[2].darkMode = {
        iconResource: $r('sys.symbol.screen_rotation'),
        iconTitle: this.screenOrientation === ScreenOrientation.PORTRAIT ? $r('app.string.landscape_screen') :
          $r('app.string.portrait_screen'),
      }
    }
  }

  private handleShare(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const shareDescription = ResourceUtil.getResourceString(context, $r('app.string.share_description'));
    const shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      content: this.code,
      title: this.componentName,
      description: shareDescription
    });

    const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DEFAULT
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `Component code sharing error. Code: ${error.code}, message: ${error.message}`);
    });
  }

  copyText(text: string) {
    try {
      const pasteboardData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData).then(() => {
        Toast.showToast($r('app.string.copy_success'))
      }).catch((error: BusinessError) => {
        Toast.showToast($r('app.string.copy_fail'));
        Logger.error(TAG, `Copy data failed, the code is ${error.code}}, the message is ${error.message}`);
      })
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Pasteboard invoke error, the code is ${error.code}}, the message is ${error.message}`);
    }
  }

  @Builder
  TopIconItem(resourceData: ResourceInterface | undefined, onClickIcon: (() => void) | undefined) {
    Row({ space: CommonConstants.SPACE_4 }) {
      SymbolGlyph(resourceData?.iconResource)
        .fontSize($r('sys.float.Title_S'))
        .fontColor([$r('sys.color.icon_primary')])
      if (resourceData?.iconTitle !== undefined) {
        Text(resourceData?.iconTitle)
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding($r('sys.float.padding_level5'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .onClick(() => {
      onClickIcon?.();
    })
  }

  @Builder
  TopMenu() {
    Row({ space: CommonConstants.SPACE_8 }) {
      ForEach(this.topIconItems, (item: ItemData) => {
        this.TopIconItem(this.isDarkMode ? item?.darkMode : item?.lightMode, item?.onClickIcon
        )
      }, (_item: ItemData, index: number) => index.toString())
    }
    .justifyContent(FlexAlign.End)
    .padding({
      top: $r('sys.float.padding_level6'),
    })
  }

  @Builder
  BottomMenu() {
    Row() {
      ForEach(this.bottomIconItems, (item: ItemData) => {
        BottomIconItem({
          isDark: this.isDarkMode,
          itemData: item,
        })
      }, (_item: ItemData, index: number) => index.toString())
    }
    .translate({ y: this.bottomTranslateY })
    .width('100%')
    .height(CommonConstants.TAB_BAR_HEIGHT + this.globalInfoModel.naviIndicatorHeight)
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ bottom: this.globalInfoModel.naviIndicatorHeight })
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
  }

  @Builder
  TopNavigationMenu() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
      Row({ space: CommonConstants.SPACE_8 }) {
        ForEach(this.topMenuList, (item: ItemData, index: number) => {
          Button() {
            SymbolGlyph(this.isDarkMode ? item.darkMode.iconResource : item.lightMode.iconResource)
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r('sys.color.icon_primary')])
              .opacity(this.isFocus ? 1 : 0.4)
          }
          .height($r('app.float.code_preview_top_navigation_height'))
          .aspectRatio(1)
          .hoverEffect(HoverEffect.Highlight)
          .backgroundColor(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? Color.Transparent :
            $r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            item.onClickIcon();
          })
        }, (index: number) => index.toString())
      }
      .margin({
        right: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
          $r('app.float.code_preview_icon_margin') : 0
      })
    }
  }

  @Builder
  TopNavigationViewBuilder() {
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
      .translate({ y: this.topTranslateY })
      .position({ x: 0, y: 0 })
      .opacity(this.navigationOpacity)
  }

  @Styles
  normalStyles(): void {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  @Styles
  focusStyles(): void {
    .borderColor($r('sys.color.comp_emphasize_tertiary'))
    .borderWidth($r('app.float.toolbar_focus_border_width'))
  }

  @Builder
  Toolbar() {
    Divider()
      .width('100%')
      .margin({
        top: $r('sys.float.padding_level6'),
        left: $r('sys.float.padding_level4'),
        right: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level2'),
      })
    Row({ space: CommonConstants.SPACE_8 }) {
      Text($r('app.string.copy_code'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
      SymbolGlyph($r('sys.symbol.plus_square_on_square'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor([$r('sys.color.icon_primary')])
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => this.copyText(this.code))
    .padding({
      top: $r('sys.float.padding_level4'),
      bottom: $r('sys.float.padding_level4'),
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4'),
    })
    .hoverEffect(HoverEffect.Highlight)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
      focused: this.focusStyles,
    })
    .borderRadius($r('sys.float.corner_radius_level6'))
  }

  @Builder
  WebOverlay() {
    Row()
      .width('100%')
      .height($r('app.float.web_overlay_height'))
      .linearGradient({
        colors: [[$r('app.color.web_overlay_color_start'), 0], [$r('sys.color.comp_background_primary'), 1]]
      })
      .visibility(this.pageContainer ? Visibility.None : Visibility.Visible)
  }

  build() {
    WithTheme({ colorMode: this.isDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
      Column() {
        Stack() {
          NodeContainer(this.webNodeController)
            .backgroundColor($r('app.color.code_preview_web_bg'))
            .overlay(this.WebOverlay(), { align: Alignment.Bottom })
          if (this.pageContainer === true) {
            this.TopNavigationViewBuilder()
            if (this.globalInfoModel.widthBreakpoint !== WidthBreakpoint.WIDTH_XL) {
              this.BottomMenu()
            }
          } else {
            this.TopMenu()
          }
        }
        .layoutWeight(1)
        .alignContent(this.pageContainer ? Alignment.Bottom : Alignment.TopEnd)
        .margin({
          left: this.pageContainer ? 0 : $r('sys.float.padding_level4'),
          right: this.pageContainer ? 0 : $r('sys.float.padding_level4'),
        })

        if (!this.pageContainer) {
          this.Toolbar()
        }
      }
      .onAppear(() => {
        if (this.pageContainer) {
          this.handleDeviceOrientation();
        }
      })
      .onDisAppear(() => {
        WindowUtil.disableFloatWindowRotate();
      })
      .backgroundColor($r('sys.color.comp_background_primary'))
      .padding(this.pageContainer === false ? {
        left: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level2'),
        bottom: $r('sys.float.padding_level2'),
      } : $r('sys.float.padding_level0'))
      .width('100%')
      .height('100%')
    }
  }
}

@Component
struct BottomIconItem {
  @Link isDark: boolean;
  @ObjectLink itemData: ItemData | undefined;

  build() {
    Column() {
      SymbolGlyph(this.isDark ? this.itemData?.darkMode.iconResource : this.itemData?.lightMode.iconResource)
        .fontSize($r('sys.float.Title_M'))
        .fontColor([$r('sys.color.icon_secondary')])
      Text(this.isDark ? this.itemData?.darkMode.iconTitle : this.itemData?.lightMode.iconTitle)
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: $r('sys.float.padding_level2') })
    }
    .height('100%')
    .aspectRatio(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.itemData?.onClickIcon();
    })
  }
}

@Observed
class ResourceInterface {
  public iconResource?: Resource;
  public iconTitle?: ResourceStr;
}

@Observed
class ItemData {
  public id: number;
  public lightMode: ResourceInterface;
  public darkMode: ResourceInterface;
  public onClickIcon: () => void;

  constructor(lightMode: ResourceInterface, onClickIcon: () => void, index: number, darkMode?: ResourceInterface) {
    this.lightMode = lightMode;
    this.darkMode = darkMode || lightMode;
    this.onClickIcon = onClickIcon;
    this.id = index;
  }
}