/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants, GlobalInfoModel, HmosListItem, StorageKey } from '@ohos/common';
import { AlertDialog } from '@kit.ArkUI';
import { SettingState } from '../viewmodel/SettingState';
import { InitEvent, LogoutEvent, SettingPageVM } from '../viewmodel/SettingPageVM';

@Component
struct SettingView {
  pathStack: NavPathStack = new NavPathStack();
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  viewModel: SettingPageVM = SettingPageVM.getInstance();
  @State settingState: SettingState = this.viewModel.getState();
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.exit_dialog_title'),
      content: $r('app.string.exit_dialog_content'),
      primaryButton: {
        value: $r('app.string.exit_dialog_cancel'),
        action: () => {
          this.dialogControllerConfirm.close();
        },
      },
      secondaryButton: {
        value: $r('app.string.exit_dialog_exit'),
        role: ButtonRole.ERROR,
        action: () => {
          this.viewModel.sendEvent(new LogoutEvent(this.getUIContext()));
        },
      },
    }),
  })

  aboutToAppear(): void {
    this.viewModel.sendEvent(new InitEvent());
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        List() {
          ListItemGroup() {
            ListItem() {
              HmosListItem({
                title: $r('app.string.about'),
                handleClickAction: () => {
                  this.pathStack.pushPath({ name: 'AboutView' });
                }
              })
            }
            .padding({
              left: $r('sys.float.padding_level2'),
              right: $r('sys.float.padding_level2'),
            })
          }
          .divider({
            strokeWidth: $r('app.float.mine_divider'),
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level6'),
            endMargin: $r('sys.float.padding_level6'),
          })
          .padding({
            top: $r('sys.float.padding_level2'),
            bottom: $r('sys.float.padding_level2'),
          })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        }

        Button($r('app.string.log_out'))
          .type(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ? ButtonType.Normal :
            ButtonType.Capsule)
          .width(CommonConstants.FULL_PERCENT)
          .fontSize($r('sys.float.Subtitle_M'))
          .role(ButtonRole.ERROR)
          .buttonStyle(ButtonStyleMode.NORMAL)
          .borderRadius(AppStorage.get<boolean>(StorageKey.IS_SIDEBAR_LAYOUT) ?
            $r('sys.float.corner_radius_level4') : 0)
          .visibility(Visibility.Hidden)
          .onClick(() => {
            this.dialogControllerConfirm.open();
          })
      }
      .padding($r('sys.float.padding_level8'))
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideBackButton(true)
    .title($r('app.string.setting'))
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: $r('sys.float.padding_level4') })
    .mode(NavigationMode.Stack)
  }
}

@Builder
export function SettingViewBuilder() {
  SettingView()
}