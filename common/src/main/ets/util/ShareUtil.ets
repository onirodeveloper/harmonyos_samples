/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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
import { systemShare } from '@kit.ShareKit';
import { StorageKey } from '../constant/CommonEnums';
import Logger from './Logger';

const TAG: string = '[PasteboardUtil]';

export class ShareUtil {
  public static shareData(shareParam: systemShare.SharedRecord): void {
    const uiContext: UIContext | undefined = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    const context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
    if (!context) {
      Logger.error(TAG, `Component code sharing error.Cause context is undefined`);
      return;
    }
    const shareData: systemShare.SharedData = new systemShare.SharedData(shareParam);
    const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DEFAULT
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `Component code sharing error. Code: ${error.code}, message: ${error.message}`);
    });
  }
}
