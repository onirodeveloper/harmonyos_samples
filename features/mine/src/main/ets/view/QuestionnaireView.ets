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

import { GlobalInfoModel, StorageKey } from '@ohos/common';
import { QuestionnaireState } from '../viewmodel/QuestionnaireState';
import { QuestionnaireVM, SelectScoreEvent, SubmitEvent } from '../viewmodel/QuestionnaireVM';

@Component
export struct QuestionnaireView {
  private viewModel: QuestionnaireVM = QuestionnaireVM.getInstance();
  @State questionnaireState: QuestionnaireState = this.viewModel.getState();
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  private colorResources: Resource[] = [$r('app.color.questionnaire_color_1'), $r('app.color.questionnaire_color_2'),
    $r('app.color.questionnaire_color_3'), $r('app.color.questionnaire_color_4'), $r('app.color.questionnaire_color_5'),
    $r('app.color.questionnaire_color_6'), $r('app.color.questionnaire_color_7'), $r('app.color.questionnaire_color_8'),
    $r('app.color.questionnaire_color_9'), $r('app.color.questionnaire_color_10')];

  build() {
    Navigation() {
      Column() {
        Text($r('app.string.score_title'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: $r('sys.float.padding_level8') })

        Row() {
          ForEach(Array.from({ length: 10 }), (item: number, index: number) => {
            Column() {
              Text(`${index + 1}`)
                .fontSize($r('sys.float.Subtitle_S'))
                .fontColor(this.questionnaireState.selectedScore >= (index + 1) ? $r('sys.color.font_on_primary') :
                  $r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
            }
            .width($r('app.float.score_area_width'))
            .height($r('app.float.score_area_height'))
            .align(Alignment.Center)
            .justifyContent(FlexAlign.Center)
            .borderRadius($r('sys.float.corner_radius_level2'))
            .backgroundColor(this.questionnaireState.selectedScore >= (index + 1) ? this.colorResources[index] :
              $r('sys.color.comp_background_list_card'))
            .onClick(() => {
              this.viewModel.sendEvent(new SelectScoreEvent(index + 1));
            })
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? '100%' :
          $r('app.float.score_list_width_md_lg'))
        .margin({ bottom: $r('sys.float.padding_level8') })

        Text($r('app.string.description_title'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: $r('sys.float.padding_level8') })

        TextArea({
          placeholder: $r('app.string.input_placeholder'),
          text: this.questionnaireState.questionnaireInput,
        })
          .maxLines(25)
          .showCounter(true, { thresholdPercentage: 1 })
          .maxLength(500)
          .borderRadius($r('sys.float.corner_radius_level8'))
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .height($r('app.float.feedback_input_height'))
          .textAlign(TextAlign.Start)
          .align(Alignment.TopStart)
          .margin({ bottom: $r('sys.float.padding_level8') })
          .onEditChange((editStatus: boolean) => {
            this.questionnaireState.editStatus = editStatus;
          })
          .onChange((value: string) => {
            this.questionnaireState.questionnaireInput = value;
          })

        Blank()

        Button($r('app.string.submit'))
          .height($r('app.float.feedback_submit_height'))
          .width('100%')
          .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
            $r('sys.float.corner_radius_level4') : '50%')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .controlSize(ControlSize.NORMAL)
          .enabled(this.questionnaireState.selectedScore > 0)
          .onClick(() => {
            this.viewModel.sendEvent(new SubmitEvent());
          })
      }
      .alignItems(HorizontalAlign.Start)
      .height('100%')
      .width('100%')
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideBackButton(true)
    .title($r('app.string.user_experience'), {
      backgroundColor: $r('sys.color.background_secondary')
    })
    .titleMode(NavigationTitleMode.Mini)
    .padding({
      top: $r('sys.float.padding_level9'),
      bottom: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM &&
        this.globalInfoModel.naviIndicatorHeight > 0 ?
        this.globalInfoModel.naviIndicatorHeight : $r('sys.float.padding_level8'),
    })
    .mode(NavigationMode.Stack)
  }
}

@Builder
export function QuestionnaireViewBuilder() {
  QuestionnaireView()
}