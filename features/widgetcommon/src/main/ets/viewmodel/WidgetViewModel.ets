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
import { formProvider } from '@kit.FormKit';
import { Logger } from '@ohos/common';

const TAG: string = '[WidgetVM]'

export class WidgetViewModel {
  public static setAlignRules(verticalName: string, verticalAlign: VerticalAlign,
    horizontalName: string, horizontalAlign: HorizontalAlign): Record<string, AlignParam> {

    let alignRule: Record<string, AlignParam> = {};
    alignRule[verticalName] = { 'anchor': '__container__', 'align': verticalAlign };
    alignRule[horizontalName] = { 'anchor': '__container__', 'align': horizontalAlign };
    return alignRule;
  }

  public static cancelOverFlow(formId: string) {
    try {
      formProvider.cancelOverflow(formId)
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `Error ${error.code}: Failed to get localStorage @LiveFormWidget.onClick.` +
        `Message: ${error.message}`);
    }
  }
}

type AlignParam = Record<string, string | VerticalAlign | HorizontalAlign>;

@Component
export struct WidgetStaticCard {
  build() {
    RelativeContainer() {
      // Fluffy on the left side
      Image($r('app.media.Fluffy_Ori'))
        .height('100%')
        .alignRules(WidgetViewModel.setAlignRules('bottom', VerticalAlign.Bottom, 'middle', HorizontalAlign.Center))
        .translate({
          x: 0,
        })
      // Text
      Row() {
        Column() {
          Text($r('app.string.widget_hmos_coding_title'))
            .minFontSize(8)
            .maxFontSize(12)
            .fontColor(Color.Black)
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
      }
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
  }
}
