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
  }
}