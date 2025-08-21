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

import { CommonConstants } from '../constant/CommonConstants';
import { StorageKey } from '../constant/CommonEnums';
import { BreakpointTypeEnum, type GlobalInfoModel } from '../model/GlobalInfoModel';
import { BreakpointType } from '../util/BreakpointSystem';

const BACK_ICON_WIDTH: number = 40;
const TOTAL_PADDING: number = 40;

/**
 * Custom Title Block
 */

@Component
export struct TopNavigationView {
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('calculateTitleSize') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO)!;
  @StorageProp(StorageKey.BLUE_RENDER_GROUP) blurRenderGroup: boolean = false;
  @Prop topNavigationData: TopNavigationData = new TopNavigationData();
  @BuilderParam menuView?: () => void;
  @State fontSize: number = 20;
  @State backIconBgColor: ResourceColor =
    this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? Color.Transparent :
    $r('sys.color.comp_background_tertiary');

  aboutToAppear(): void {
    if (this.topNavigationData.fontSize === undefined) {
      this.calculateTitleSize();
    }
  }

  calculateTitleSize(): void {
    const uiContext: UIContext = this.getUIContext();
    const maxWidth = this.globalInfoModel.deviceWidth - BACK_ICON_WIDTH - TOTAL_PADDING;
    let currentFontSize: number = this.fontSize;
    let titleWidth: number = Math.ceil(uiContext.px2vp(uiContext.getMeasureUtils().measureText({
      textContent: this.topNavigationData.title,
      fontWeight: FontWeight.Bold,
      fontSize: currentFontSize,
    })));
    while (currentFontSize > 14 && titleWidth > maxWidth) {
      currentFontSize--;
      titleWidth = Math.ceil(uiContext.px2vp(uiContext.getMeasureUtils().measureText({
        textContent: this.topNavigationData.title,
        fontWeight: FontWeight.Bold,
        fontSize: currentFontSize,
      })));
    }
    this.fontSize = currentFontSize;
  }

  build() {
    Column() {
      Row() {
        if (this.topNavigationData.onBackClick) {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize($r('sys.float.Title_M'))
          }
          .height($r('app.float.back_button_height'))
          .aspectRatio(1)
          .margin({ right: $r('sys.float.padding_level4') })
          .backgroundColor(this.backIconBgColor)
          .onClick(() => this.topNavigationData.onBackClick?.())
          .onHover((isHover: boolean) => {
            this.backIconBgColor = isHover ? $r('sys.color.comp_background_tertiary') : Color.Transparent;
          })
        }

        Text(this.topNavigationData.title)
          .fontSize(this.topNavigationData.fontSize ? this.topNavigationData.fontSize : this.fontSize)
          .fontColor(this.topNavigationData.titleColor)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Row() {
          this.menuView?.()
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(CommonConstants.NAVIGATION_HEIGHT)
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        },
      }).getValue(this.globalInfoModel.currentBreakpoint))

      Divider()
        .color($r('sys.color.comp_divider'))
        .visibility(this.topNavigationData.isBlur ? Visibility.Visible : Visibility.Hidden)
    }
    .backgroundBlurStyle(this.topNavigationData.isBlur ? BlurStyle.COMPONENT_THICK : undefined)
    .renderGroup(!this.blurRenderGroup && this.globalInfoModel.currentBreakpoint !== BreakpointTypeEnum.XL)
    .padding({ top: this.topNavigationData.isFullScreen ? this.globalInfoModel.statusBarHeight : 0 })
    .width('100%')
    .backgroundColor(this.topNavigationData.bgColor)
  }
}

@Observed
export class TopNavigationData {
  public title: ResourceStr = '';
  public fontSize?: ResourceStr;
  public isFullScreen?: boolean = true;
  public titleColor?: ResourceStr = $r('sys.color.font_primary');
  public isBlur?: boolean = false;
  public bgColor?: ResourceStr | Color = Color.Transparent;
  public onBackClick?: Function;
}