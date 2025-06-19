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

import { common } from '@kit.AbilityKit';
import { ArcList, ArcListAttribute, ArcListItem, LengthMetrics, ComponentContent } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { MediaTypeEnum } from '@ohos/commonbusiness';
import { WearableSampleData } from '../model/WearableSampleData';

const ITEM_SPACE: number = 6;
const ITEM_WIDTH: string = '88%';
const TAG: string = '[SampleListComponent]';

@Builder
function SampleListHeader() {
  Column() {
    Text($r('app.string.sample_library'))
      .fontSize($r('app.float.item_title_size'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_on_primary'))
      .padding({
        top: $r('sys.float.padding_level3'),
        bottom: $r('sys.float.padding_level2'),
      })
    Text($r('app.string.watch_development_sample'))
      .fontSize($r('sys.float.Subtitle_M'))
      .fontWeight(FontWeight.Regular)
      .fontColor($r('sys.color.font_on_secondary'))
  }
}

@Component
export struct SampleListComponent {
  context: UIContext = this.getUIContext();
  sampleListHeader: ComponentContent<[]> = new ComponentContent(this.context, wrapBuilder(SampleListHeader));
  @State wearableSampleList: WearableSampleData[] = [];

  @Builder
  SampleListItem(wearableSampleData: WearableSampleData) {
    Row() {
      if (wearableSampleData.mediaType === MediaTypeEnum.SYMBOL) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r(wearableSampleData.mediaUrl))
            .fontSize($r('app.float.icon_size'))
            .fontColor([$r('sys.color.font_on_primary')])
        }
        .width($r('app.float.button_size'))
        .height($r('app.float.button_size'))
        .backgroundColor(wearableSampleData.symbolGlyphColor)
      } else if (wearableSampleData.mediaType == MediaTypeEnum.IMAGE) {
        Image($r(wearableSampleData.mediaUrl))
          .width($r('app.float.button_size'))
          .height($r('app.float.button_size'))
      }

      Column() {
        Text(wearableSampleData.title)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('app.float.item_title_size'))
        Text(wearableSampleData.desc)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_on_secondary'))
          .fontSize($r('app.float.item_description_size'))
      }

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize($r('app.float.icon_size'))
        .fontColor([$r('sys.color.icon_secondary')])
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(ITEM_WIDTH)
    .borderRadius($r('app.float.item_border_radius'))
    .padding({
      top: $r('sys.float.padding_level6'),
      bottom: $r('sys.float.padding_level5'),
      left: $r('sys.float.padding_level3'),
      right: $r('sys.float.padding_level3'),
    })
    .backgroundColor($r('app.color.item_background'))
    .onClick(() => {
      const ctx: common.UIAbilityContext = getContext() as common.UIAbilityContext;
      const moduleAbility: string = wearableSampleData.abilityName;
      try {
        ctx.startAbility({
          bundleName: ctx.abilityInfo.bundleName,
          abilityName: moduleAbility
        }).then(() => {
          Logger.info(TAG, `start ${moduleAbility} success}`);
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `start ${moduleAbility} failed, message is ${error.message}`);
        });
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `startAbility failed, message is ${err.message}`);
      }
    })
  }

  build() {
    ArcList({ header: this.sampleListHeader }) {
      ForEach(this.wearableSampleList, (item: WearableSampleData) => {
        ArcListItem() {
          this.SampleListItem(item)
        }
      }, (item: WearableSampleData) => item.id.toString())
    }
    .space(LengthMetrics.vp(ITEM_SPACE))
    .focusable(true)
    .focusOnTouch(true)
    .defaultFocus(true)
  }
}