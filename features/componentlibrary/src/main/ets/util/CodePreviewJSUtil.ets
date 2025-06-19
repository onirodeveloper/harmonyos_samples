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

import type { BusinessError } from '@kit.BasicServicesKit';
import { Logger, WebUtil } from '@ohos/common';

const TAG: string = '[CodePreviewJSUtil]';

export class CodePreviewJSUtil {
  public static codeViewRunJS(jsMethod: string, params?: string, callback?: Function): void {
    if (WHITE_JS_METHODS.indexOf(jsMethod) >= 0) {
      let runMethod = jsMethod;
      if (params && params.trim() !== '') {
        runMethod = runMethod.replace('%param', params);
      }
      try {
        const promise = WebUtil.getWebController(WebUtil.getComponentCodeUrl())?.runJavaScript(runMethod);
        callback && promise?.then(() => {
          callback();
        })
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        Logger.error(TAG, `RunJavaScript error, the code is ${error.code}, the message is ${error.message}`);
      }
    } else {
      Logger.error(TAG, `Input method ${jsMethod} not in whitelist`);
    }
  }
}

const WHITE_JS_METHODS = [
  'changeColorMode(%param)',
  'showPortraitView()',
  'codeToHtml(%param)',
  'toFullScreen()',
  'toSmallScreen()',
  'showLandscapeView(%param)',
];