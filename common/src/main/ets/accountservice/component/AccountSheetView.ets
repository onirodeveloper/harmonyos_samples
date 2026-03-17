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

import { AlertDialog } from '@kit.ArkUI';
import { CommonConstants } from '../../constant/CommonConstants';
import type { GlobalInfoModel } from '../../model/GlobalInfoModel';
import { StorageKey } from '../../constant/CommonEnums';
import { UserAccount } from '../model/UserAccount';
import { AccountService } from '../AccountService';

@Builder
export function LoginSheetViewBuilder(userAccount: UserAccount) {
  AccountSheetView({ userAccount })
}

@Component
struct AccountSheetView {
  @Prop @Require userAccount: UserAccount;
  @StorageProp(StorageKey.GLOBAL_INFO) globalInfoModel?: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO);
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
          AccountService.getInstance().logoutDirect();
        },
      },
    }),
  })

  build() {
    Row() {
      Column() {
        Column() {
          SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
            .fontSize($r('sys.float.Display_L'))
            .fontColor([$r('sys.color.icon_emphasize')])
            .aspectRatio(1)
          Text(!AccountService.getInstance().userLogin ? $r('app.string.select_account_title') :
            $r('app.string.current_account'))
            .margin({ top: $r('sys.float.padding_level6') })
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: $r('sys.float.padding_level10') })
          Image(this.userAccount.avatarUrl)
            .draggable(false)
            .width($r('app.float.account_sheet_view_avatar_size'))
            .aspectRatio(1)
            .borderRadius($r('app.float.account_sheet_view_avatar_border_radius'))
            .margin({ top: $r('app.float.account_sheet_view_avatar_margin') })
          Text(this.userAccount.nickname)
            .margin($r('sys.float.padding_level12'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .margin({ top: $r('sys.float.padding_level16') })

        Blank();

        Button(!AccountService.getInstance().userLogin ? $r('app.string.select_account_to_log_in') :
          $r('app.string.log_out'))
          .type(this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_XL ? ButtonType.Normal :
            ButtonType.Capsule)
          .fontSize($r('sys.float.Subtitle_M'))
          .role(!AccountService.getInstance().userLogin ? ButtonRole.NORMAL : ButtonRole.ERROR)
          .buttonStyle(!AccountService.getInstance().userLogin ? ButtonStyleMode.EMPHASIZED : ButtonStyleMode.NORMAL)
          .borderRadius(this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_XL ?
            $r('sys.float.corner_radius_level4') : 0)
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: $r('sys.float.padding_level5') })
          .onClick(() => {
            if (!AccountService.getInstance().userLogin) {
              AccountService.getInstance().selectHuaweiAccountToLogin();
            } else {
              this.dialogControllerConfirm.open();
            }
          })
      }
      .borderRadius(this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_SM ?
        { topLeft: $r('sys.float.corner_radius_level12'), topRight: $r('sys.float.corner_radius_level12') } :
        $r('sys.float.corner_radius_level12'))
      .padding({
        right: $r('sys.float.padding_level8'),
        bottom: this.globalInfoModel?.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? $r('sys.float.padding_level16') :
          $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8'),
      })
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
  }
}