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

import { TextModifier } from '@kit.ArkUI';
import {
  HdsListItemCard,
  HdsListItemCardAttribute,
  PrefixCustomBuilder,
  SuffixButton,
  SuffixCustomBuilder
} from '@kit.UIDesignKit';
import {
  ImageUtil,
  ResourceUtil,
  TagEnum,
  TRACK_KEY,
  TrackNode,
  TrackServiceData,
  InteractionTypeEnum,
  ActionName,
  CommonConstants,
} from '@ohos/common';
import { TagTipLabel } from '@ohos/commonbusiness';
import type { ComponentContent } from '../model/ComponentData';

export enum ItemSuffixType {
  BUTTON = 'button',
  ICON = 'icon',
}

@Component
export struct ComponentItemList {
  @Prop @Require cardContents: ComponentContent[];
  @Prop @Require widthBreakpoint: WidthBreakpoint;
  @Prop itemHeight: Resource = $r('app.float.component_item_height');
  @Prop suffixType: ItemSuffixType = ItemSuffixType.BUTTON;
  @Prop buttonColor: ResourceColor = $r('sys.color.interactive_active');
  handleItemClick?: Function;

  @Builder
  CircleArrowBuilder() {
    Row() {
      CircleArrow()
    }
    .padding({ right: $r('sys.float.padding_level4') })
  }

  @Builder
  IconBuilder(iconUrl: ResourceStr, showTag: boolean, tagIds: TagEnum[], buttonColor: ResourceColor) {
    ComponentIcon({ iconUrl, showTag, tagIds, buttonColor })
  }

  build() {
    List() {
      Repeat(this.cardContents)
        .each((repeatItem: RepeatItem<ComponentContent>) => {
          ListItem() {
            TrackNode() {
              Column() {
                HdsListItemCard({
                  prefixItem: new PrefixCustomBuilder(() => {
                    this.IconBuilder(ImageUtil.getImgResource(repeatItem.item.mediaUrl),
                      this.suffixType !== ItemSuffixType.ICON, repeatItem.item.tagIds, this.buttonColor);
                  }),
                  textItem: {
                    primaryText: {
                      text: repeatItem.item.subTitle,
                      modifier:
                      new TextModifier()
                        .maxLines(1)
                        .ellipsisMode(EllipsisMode.END)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .fontColor(this.suffixType === ItemSuffixType.BUTTON ? $r('sys.color.font_primary') :
                          $r('sys.color.font_on_primary')),
                    },
                    secondaryText: {
                      text: repeatItem.item.title,
                      modifier: new TextModifier()
                        .maxLines(1)
                        .ellipsisMode(EllipsisMode.END)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .fontColor(this.suffixType === ItemSuffixType.BUTTON ? $r('sys.color.font_secondary') :
                          $r('sys.color.font_on_primary'))
                    }
                  },
                  suffixItem: this.suffixType === ItemSuffixType.BUTTON ?
                    new SuffixButton({ text: $r('app.string.open'), textColor: this.buttonColor }) :
                    new SuffixCustomBuilder(() => this.CircleArrowBuilder()),
                  cardHeight: this.itemHeight,
                  cardPrefixMargin: $r('sys.float.padding_level0'),
                  cardSuffixMargin: $r('sys.float.padding_level2'),
                  cardBorderRadius: 0,
                  cardBackgroundColor: $r('sys.color.ohos_id_color_background_transparent'),
                })
              }
              .customProperty(TRACK_KEY, {
                interactionContent: repeatItem.item.title,
                interactionType: InteractionTypeEnum.COMPONENT,
                actionName: ActionName.COMPONENT_CLICK,
              } as TrackServiceData)
            }
          }
          .onClick(this.handleItemClick ? () => {
            this.handleItemClick?.(repeatItem.item);
          } : undefined)
        })
        .key((componentContent: ComponentContent) => componentContent.id.toString())
    }
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_background_tertiary'),
      startMargin: $r('sys.float.padding_level36'),
      endMargin: $r('sys.float.padding_level6')
    })
    .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .width('100%')
    .height(this.cardContents.length *
    this.getUIContext().px2vp(ResourceUtil.getResourceNumber(this.getUIContext().getHostContext(), this.itemHeight)))
  }
}

@Component
struct CircleArrow {
  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.icon_secondary')])
        .fontSize($r('sys.float.Title_M'))
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width($r('app.float.arrow_size'))
    .aspectRatio(1)
  }
}

@Component
struct ComponentIcon {
  @Prop showTag: boolean;
  @Prop tagIds: TagEnum[];
  @Prop @Require iconUrl: ResourceStr;
  @Prop buttonColor: ResourceColor;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.iconUrl)
        .draggable(false)
        .borderRadius($r('sys.float.corner_radius_level5'))
        .width($r('app.float.tip_image_height'))
        .margin({
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level8'),
        })
        .aspectRatio(1)
        .backgroundColor(this.buttonColor)
        .animation({
          duration: CommonConstants.ANIMATION_DURATION,
          curve: Curve.EaseIn
        })
      if (this.showTag) {
        TagTipLabel({ tags: this.tagIds, isSmall: true })
          .margin({
            left: $r('sys.float.padding_level3'),
            top: $r('app.float.small_new_margin_top'),
          })
      }
    }
  }
}