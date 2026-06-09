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
/** Warning
 * Do NOT import { anything } from '@ohos/common'
 * may cause unexpected problem,
 **/

type AlignParam = Record<string, string | VerticalAlign | HorizontalAlign>;

function setAlignRules(verticalName: string, verticalAlign: VerticalAlign,
  horizontalName: string, horizontalAlign: HorizontalAlign): Record<string, AlignParam> {

  let alignRule: Record<string, AlignParam> = {};
  alignRule[verticalName] = { 'anchor': '__container__', 'align': verticalAlign };
  alignRule[horizontalName] = { 'anchor': '__container__', 'align': horizontalAlign };
  return alignRule;
};

let storageUpdateCall = new LocalStorage();

@Entry(storageUpdateCall)
@Component
struct Hmos_3d_live_widgetCard {
  @LocalStorageProp('formId') formId: string = '';
  /*
  * The max lines.
  */
  readonly maxLines: number = 1;
  /*
  * The action type.
  */
  readonly actionType: string = 'router';
  /*
  * The message.
  */
  readonly message: string = 'add detail';
  /*
  * The ability name.
  */
  readonly abilityName: string = 'EntryAbility';
  /*
  * The width percentage setting.
  */
  readonly fullWidthPercent: string = '100%';
  /*
  * The height percentage setting.
  */
  readonly fullHeightPercent: string = '100%';

  build() {
    RelativeContainer() {
      // Fluffy on the left side
      Image($r('app.media.Fluffy_Ori'))
        .height('100%')
        .alignRules(setAlignRules('bottom', VerticalAlign.Bottom, 'middle', HorizontalAlign.Center))
        .translate({
          x: 0,
        })
      // Text
      Row() {
        Column() {
          Text($r('app.string.widget_hmos_coding_title'))
            .minFontSize(8)
            .maxFontSize(12)
            .fontWeight(FontWeight.Medium)
            .margin({
              bottom: 2
            })
          Text($r('app.string.widget_hmos_coding_text'))
            .minFontSize(6)
            .maxFontSize(10)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)
        // [End of Column]
      } // Row
      .alignRules({
        'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
        'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
        'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
      })
      .backgroundColor('rgba(255, 255, 255, 0.85)')
      .borderRadius(13)
      .padding({
        top: 6,
        bottom: 6,
        left: 13,
        right: 8,
      })
      .id('row')
      .margin(8)
      .onClick(() => {
        // onClick on the text, jump to mainPage and switch to naviTab of Sample-List-Page
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            'isFromShortCut': 'true',
            'shortCutKey': 'SampleListPage',
          },
        });
      })
      // [End of Row id = 'row']
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      postCardAction(this, {
        action: 'message',
        abilityName: 'PhoneFormAbility',
        params: {
          message: 'requestOverFlow'
        }
      })
    })
    // [End of RelativeContainer]
  } // [End of build()]
}