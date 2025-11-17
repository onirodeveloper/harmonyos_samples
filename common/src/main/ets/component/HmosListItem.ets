/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { SymbolGlyphModifier } from '@kit.ArkUI';
import {
  HdsListItemCard,
  HdsListItemCardAttribute,
  IconSize,
  PrefixIcon,
  SuffixArrow,
  SuffixBadgeAndArrow,
  SuffixButton,
  SuffixText,
} from '@kit.UIDesignKit';
import { SuffixItem } from '@hms.hds.hdsBaseComponent';
import { CommonConstants } from '../constant/CommonConstants';
import { VersionUtil } from '../util/VersionUtil';

@Component
export struct HmosListItem {
  @Prop prefixResource: Resource;
  @Prop prefixColor: ResourceColor = $r('sys.color.icon_secondary');
  @Prop title: ResourceStr;
  @Prop subTitle: ResourceStr;
  @Prop desc: ResourceStr;
  @Prop badgeNum: number;
  @Prop buttonTitle: ResourceStr;
  @Prop itemHeight: Dimension = $r('app.float.item_card_height');
  @Prop widthBreakpoint: WidthBreakpoint;
  handleClickAction?: Function;

  getSuffixItem(): SuffixItem {
    if (this.buttonTitle) {
      return new SuffixButton({ text: this.buttonTitle });
    } else if (this.badgeNum) {
      return new SuffixBadgeAndArrow({
        badgeValue: this.badgeNum,
        badgeColor: $r('sys.color.ohos_id_color_badge_red'),
        textColor: $r('sys.color.font_on_primary'),
      }, {
        color: $r('sys.color.icon_fourth'),
      });
    } else if (this.desc) {
      return new SuffixText({
        text: this.desc,
      })
    } else {
      return new SuffixArrow({
        color: $r('sys.color.icon_fourth'),
      });
    }
  }

  build() {
    if (VersionUtil.canUseHds()) {
      HdsListItemCard({
        prefixItem: this.prefixResource ? new PrefixIcon({
          iconSize: IconSize.SYSTEM_ICON,
          iconValue: {
            symbol: new SymbolGlyphModifier(this.prefixResource)
              .fontColor([this.prefixColor])
          },
        }) : undefined,
        textItem: {
          primaryText: {
            text: this.title,
          },
          secondaryText: this.subTitle ? { text: this.subTitle } : undefined,
        },
        suffixItem: this.getSuffixItem(),
        cardBorderRadius: $r('sys.float.corner_radius_level8'),
        cardPrefixMargin: 0,
        cardSuffixMargin: 0,
        cardHeight: this.itemHeight,
        cardBackgroundColor: $r('sys.color.ohos_id_color_background_transparent'),
        onClick: this.handleClickAction ? () => {
          this.handleClickAction?.();
        } : undefined,
      })
    } else {
      Row() {
        if (this.prefixResource) {
          SymbolGlyph(this.prefixResource)
            .fontSize($r('sys.float.Title_M'))
            .margin({ right: $r('sys.float.padding_level6') })
            .fontColor([this.prefixColor])
        }
        Column({ space: CommonConstants.SPACE_2 }) {
          Text(this.title)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Text(this.subTitle)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .visibility(this.subTitle ? Visibility.Visible : Visibility.None)
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ right: $r('sys.float.padding_level6') })
        .layoutWeight(1)

        if (this.buttonTitle) {
          Button(this.buttonTitle,
            { type: ButtonType.Normal, buttonStyle: ButtonStyleMode.NORMAL, controlSize: ControlSize.SMALL })
            .borderRadius(this.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
              $r('sys.float.corner_radius_level4') : '50%')
            .width($r('app.float.small_button_width'))
            .fontColor($r('sys.color.interactive_active'))
        } else if (this.desc) {
          Text(this.desc)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
        } else {
          if (this.badgeNum) {
            Row() {
              Text(String(this.badgeNum))
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Caption_M'))
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius($r('sys.float.corner_radius_level8'))
            .padding({ left: $r('sys.float.corner_radius_level2'), right: $r('sys.float.corner_radius_level2') })
            .height($r('app.float.badge_size'))
            .constraintSize({ minWidth: $r('app.float.badge_size') })
            .backgroundColor($r('sys.color.warning'))
            .margin({ right: $r('sys.float.corner_radius_level2') })
          }
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_fourth')])
            .fontSize($r('sys.float.Title_M'))
        }
      }
      .hoverEffect(this.handleClickAction ? HoverEffect.Highlight : HoverEffect.None)
      .stateStyles({
        pressed: this.pressedStyle,
        normal: this.normalStyles,
      })
      .onClick(() => {
        this.handleClickAction?.();
      })
      .width('100%')
      .height(this.itemHeight)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .alignItems(VerticalAlign.Center)
      .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    }
  }

  @Styles
  pressedStyle() {
    .backgroundColor(this.handleClickAction ? $r('sys.color.comp_background_secondary') : Color.Transparent)
  }

  @Styles
  normalStyles(): void {
    .backgroundColor(Color.Transparent)
  }
}