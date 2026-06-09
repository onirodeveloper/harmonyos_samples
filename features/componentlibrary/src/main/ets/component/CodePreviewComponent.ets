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
import { CommonModifier } from '@kit.ArkUI';
import {
  ActionName,
  InteractionTypeEnum,
  CommonConstants,
  GlobalInfoModel,
  StorageKey,
  TRACK_KEY,
  TrackServiceData,
  WebNodeController,
  WindowUtil,
  PasteboardUtil,
} from '@ohos/common';
import { CustomToolBarItem } from '../model/CustomToolBarItem';
import { CodePreviewJSUtil } from '../util/CodePreviewJSUtil';

@Component
export struct CodePreviewComponent {
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel = new GlobalInfoModel();
  @Prop @Watch('handleColorModeChange') isDarkMode: boolean;
  @Prop @Watch('flushCode') code: string = '';
  @Prop nodeContainerPaddingLeft: ResourceStr;
  @Prop nodeContainerPaddingTop: ResourceColor;
  @Prop pageContainer: boolean = false;
  @Link webNodeController: WebNodeController;
  @State commonModifier: CommonModifier = new CommonModifier();
  public pushPage?: (value: string) => void;
  public componentName: string = '';
  private topIconItems: CustomToolBarItem[] = [
    {
      symbolIcon: $r('sys.symbol.arrow_up_left_and_arrow_down_right'),
      value: '',
      actionValue: '',
      actionName: ActionName.UNKNOWN,
      action: () => {
        this.pushPage?.(this.code);
      },
    }];

  aboutToAppear(): void {
    this.commonModifier.backgroundBlurStyle(BlurStyle.BACKGROUND_THIN);
  }

  handleColorModeChange() {
    const changeColorModeMethod: string = 'changeColorMode(%param)';
    const params: string = JSON.stringify(this.isDarkMode ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    CodePreviewJSUtil.codeViewRunJS(changeColorModeMethod, params);
  }

  flushCode() {
    const codeToHtmlMethod: string = 'safeCodeToHtml(%param)';
    const params: string = JSON.stringify(this.code);
    CodePreviewJSUtil.codeViewRunJS(codeToHtmlMethod, params);
  }

  @Builder
  TopIconItem(item: CustomToolBarItem) {
    Row({ space: CommonConstants.SPACE_4 }) {
      SymbolGlyph(item.symbolIcon)
        .fontSize($r('sys.float.Title_S'))
        .fontColor([$r('sys.color.icon_primary')])
    }
    .customProperty(TRACK_KEY, {
      interactionContent: this.componentName,
      interactionType: InteractionTypeEnum.COMPONENT,
      actionName: item.actionName,
    } as TrackServiceData)
    .attributeModifier(this.commonModifier)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
      $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level10'))
    .padding($r('sys.float.padding_level5'))
    .onClick(() => {
      item.action?.();
    })
  }

  @Builder
  TopMenu() {
    Row({ space: CommonConstants.SPACE_8 }) {
      ForEach(this.topIconItems, (item: CustomToolBarItem) => {
        this.TopIconItem(item)
      }, (_item: CustomToolBarItem, index: number) => index.toString())
    }
    .justifyContent(FlexAlign.End)
    .padding({
      top: $r('sys.float.padding_level6'),
    })
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
    .customProperty(TRACK_KEY, {
      interactionContent: this.componentName,
      interactionType: InteractionTypeEnum.COMPONENT,
      actionName: ActionName.CODE_COPY,
    } as TrackServiceData)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => PasteboardUtil.copyText(this.code))
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
          if (!this.pageContainer) {
            this.TopMenu()
          }
        }
        .layoutWeight(1)
        .alignContent(this.pageContainer ? Alignment.Bottom : Alignment.TopEnd)
        .margin(this.nodeContainerPaddingLeft ?
          {
            left: this.nodeContainerPaddingLeft,
            right: this.nodeContainerPaddingLeft,
            top: this.nodeContainerPaddingTop,
          } :
          {
            left: $r('sys.float.padding_level4'),
            right: $r('sys.float.padding_level4'),
          })

        if (!this.pageContainer) {
          this.Toolbar()
        }
      }
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