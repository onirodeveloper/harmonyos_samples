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

import { common } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constant/CommonConstants';
import { StorageKey } from '../constant/CommonEnums';
import { FeedbackInitParams, FeedbackData, FeedbackType } from '../model/FeedbackData';
import { GlobalInfoModel } from '../model/GlobalInfoModel';
import { SubmitInfoUtil } from '../util/SubmitInfoUtil';
import { ResourceUtil } from '../util/ResourceUtil';
import { BreakpointType } from '../util/BreakpointSystem';
import { default as Toast } from './Toast';

@Component
export struct FeedbackSheet {
  @Link bindFeedback: boolean;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State feedbackData: FeedbackData = new FeedbackData();
  @State feedbackListState: boolean[] = [];
  @Prop feedbackInitParams: FeedbackInitParams;

  aboutToAppear(): void {
    this.initFeedbackReason();
    const maxLength = Math.max(this.feedbackData.likeReasonList.length, this.feedbackData.dislikeReasonList.length);
    this.feedbackListState = new Array(maxLength).fill(false);
  }

  private initFeedbackReason(): void {
    this.feedbackData.likeReasonList =
      ResourceUtil.getResourceStringArray((this.getUIContext().getHostContext() as common.UIAbilityContext),
        this.feedbackInitParams.likeReasonsResource);
    this.feedbackData.dislikeReasonList =
      ResourceUtil.getResourceStringArray((this.getUIContext().getHostContext() as common.UIAbilityContext),
        this.feedbackInitParams.dislikeReasonsResource);
  }

  private handleItemClick(index: number): void {
    this.feedbackListState[index] = !this.feedbackListState[index];
    this.feedbackData.listSelected = this.feedbackListState.some(listItem => listItem === true);
    this.updateSubmittable();
  }

  private handleSubmit(): void {
    if (!this.feedbackData.canSubmit) {
      Toast.showToast($r('app.string.feedback_reason'));
      return;
    }
    SubmitInfoUtil.submitFeedbackInfo(this.feedbackInitParams, this.feedbackData, this.feedbackListState);
    this.resetAllStatus();
    this.bindFeedback = false;
  }

  private handleVoteClick(currentType: FeedbackType): void {
    this.resetSubmitStatus();
    this.feedbackData.feedbackTypeStatus =
      this.feedbackData.feedbackTypeStatus === currentType ? FeedbackType.NONE : currentType;
  }

  private updateSubmittable() {
    this.feedbackData.canSubmit =
      (this.feedbackData.feedbackTypeStatus !== FeedbackType.NONE) && this.feedbackData.listSelected;
  }

  private resetSubmitStatus(): void {
    this.feedbackListState.fill(false);
    this.feedbackData.feedbackInput = '';
    this.feedbackData.listSelected = false;
    this.feedbackData.canSubmit = false;
  }

  private resetAllStatus(): void {
    this.resetSubmitStatus();
    this.feedbackData.feedbackTypeStatus = FeedbackType.NONE;
    this.feedbackData.editStatus = false;
  }

  @Builder
  FeedbackVoteBuilder(icon: Resource, label: ResourceStr, currentType: FeedbackType) {
    Column() {
      Button({ type: ButtonType.Capsule }) {
        SymbolGlyph(icon)
          .fontSize($r('sys.float.Title_M'))
          .fontColor([this.feedbackData.feedbackTypeStatus === currentType ? $r('sys.color.background_primary') :
            $r('sys.color.font_primary')])
      }
      .width($r('app.float.feedback_button_size'))
      .height($r('app.float.feedback_button_size'))
      .backgroundColor(this.feedbackData.feedbackTypeStatus === currentType ? $r('sys.color.brand') :
        $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.handleVoteClick(currentType);
      })

      Text(label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor(this.feedbackData.feedbackTypeStatus === currentType ? $r('sys.color.brand') :
          $r('sys.color.font_primary'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width($r('app.float.feedback_vote_width'))
    .height($r('app.float.feedback_vote_height'))
  }

  @Builder
  FeedbackReasonBuilder() {
    List({ space: CommonConstants.SPACE_8 }) {
      ForEach(this.feedbackData.feedbackTypeStatus === FeedbackType.LIKE ? this.feedbackData.likeReasonList :
        this.feedbackData.dislikeReasonList, (item: string, index: number) => {
        ListItem() {
          Text(item)
            .textAlign(TextAlign.Center)
            .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
              $r('sys.float.corner_radius_level4') : '50%')
            .fontColor(this.feedbackListState[index] ? $r('sys.color.brand') :
              $r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .height($r('app.float.feedback_item_height'))
            .width('100%')
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.handleItemClick(index);
            })
        }
      })
    }
    .lanes(3, $r('sys.float.padding_level4'))
    .alignListItem(ListItemAlign.Center)
    .margin({ bottom: $r('sys.float.padding_level8') })

    TextArea({
      placeholder: $r('app.string.input_placeholder'),
      text: this.feedbackData.feedbackInput,
    })
      .maxLines(CommonConstants.TEXT_INPUT_MAX_LINES)
      .showCounter(true, { thresholdPercentage: 1 })
      .maxLength(CommonConstants.TEXT_INPUT_MAX_LENGTH)
      .height($r('app.float.feedback_input_height'))
      .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
        $r('sys.float.corner_radius_level4') : $r('sys.float.corner_radius_level8'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .textAlign(TextAlign.Start)
      .align(Alignment.TopStart)
      .margin({
        bottom: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
          $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
      })
      .onEditChange((editStatus: boolean) => {
        this.feedbackData.editStatus = editStatus;
      })
      .onChange((value: string) => {
        this.feedbackData.feedbackInput = value;
      })
  }

  @Builder
  FeedbackTopBuilder() {
    Row() {
      if (this.feedbackData.feedbackTypeStatus === FeedbackType.LIKE) {
        this.FeedbackVoteBuilder($r('sys.symbol.hand_thumbsup_fill'), $r('app.string.like'), FeedbackType.LIKE)
      } else {
        this.FeedbackVoteBuilder($r('sys.symbol.hand_thumbsup'), $r('app.string.like'), FeedbackType.LIKE)
      }
      if (this.feedbackData.feedbackTypeStatus === FeedbackType.DISLIKE) {
        this.FeedbackVoteBuilder($r('sys.symbol.hand_thumbsdown_fill'), $r('app.string.dislike'), FeedbackType.DISLIKE)
      } else {
        this.FeedbackVoteBuilder($r('sys.symbol.hand_thumbsdown'), $r('app.string.dislike'), FeedbackType.DISLIKE)
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.feedback_top_height'))
    .width($r('app.float.vote_area_width'))
    .margin({ bottom: CommonConstants.SPACE_40 })
    .margin({
      bottom: this.feedbackData.feedbackTypeStatus === FeedbackType.NONE ?
        new BreakpointType({
          sm: $r('app.float.feedback_top_margin_bottom_low'),
          md: $r('app.float.feedback_top_margin_bottom_mid'),
          lg: $r('app.float.feedback_top_margin_bottom_mid'),
          xl: $r('app.float.feedback_top_margin_bottom_high')
        }).getValue(this.globalInfoModel.widthBreakpoint) :
        $r('app.float.feedback_top_margin_bottom_feedback')
    })
  }

  @Builder
  FeedbackBuilder() {
    Column() {
      this.FeedbackTopBuilder()

      if (this.feedbackData.feedbackTypeStatus !== FeedbackType.NONE) {
        this.FeedbackReasonBuilder()
      }

      if (!this.feedbackData.editStatus || deviceInfo.deviceType === CommonConstants.PC_DEVICE_TYPE) {
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
          .opacity(this.feedbackData.canSubmit ? 1 : 0.4)
          .onClick(() => {
            this.handleSubmit();
          })
      }
    }
    .padding({
      top: (this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ||
        this.feedbackData.feedbackTypeStatus !== FeedbackType.NONE) ? $r('sys.float.padding_level8') :
        $r('app.float.feedback_top_padding_md_lg'),
      left: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? $r('sys.float.padding_level12') :
        $r('sys.float.padding_level8'),
      right: this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? $r('sys.float.padding_level12') :
        $r('sys.float.padding_level8'),
      bottom: new BreakpointType({
        sm: $r('app.float.feedback_submit_padding_bottom'),
        md: $r('sys.float.padding_level8'),
        lg: $r('sys.float.padding_level8'),
        xl: $r('sys.float.padding_level12')
      }).getValue(this.globalInfoModel.widthBreakpoint)
    })
    .width('100%')
  }

  build() {
    Column() {
    }
    .bindSheet(this.bindFeedback, this.FeedbackBuilder(), {
      title: { title: $r('app.string.feedback_sheet_title') },
      preferType: SheetType.CENTER,
      height: this.feedbackData.editStatus && this.globalInfoModel.widthBreakpoint === WidthBreakpoint.WIDTH_SM ?
        SheetSize.LARGE : SheetSize.FIT_CONTENT,
      width: new BreakpointType({
        sm: $r('app.float.feedback_width_sm'),
        md: $r('app.float.feedback_width_md_lg'),
        lg: $r('app.float.feedback_width_md_lg')
      }).getValue(this.globalInfoModel.widthBreakpoint),
      onWillDisappear: () => {
        this.bindFeedback = false;
      },
      onWillAppear: () => {
        this.updateSubmittable();
      },
      keyboardAvoidMode: SheetKeyboardAvoidMode.TRANSLATE_AND_RESIZE
    })
  }
}