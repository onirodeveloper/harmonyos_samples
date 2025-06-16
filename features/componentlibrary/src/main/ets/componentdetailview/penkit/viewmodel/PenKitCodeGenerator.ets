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

import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';

export class PenKitCodeGenerator implements CommonCodeGenerator {
  public generate(_attributes: OriginAttribute[]): string {
    return `// In the src/main/ets/util path, create a ContextConfig.ts file.
import { common } from '@kit.AbilityKit';

declare namespace globalThis {
  let _brushEngineContext: common.UIAbilityContext;
};

export default class GlobalUIAbilityContext {
  static getContext(): common.UIAbilityContext {
    return globalThis._brushEngineContext;
  }

  static setContext(context: common.UIAbilityContext): void {
    globalThis._brushEngineContext = context;
  }
}

// In the src/main/ets/entryability/EntryAbility.ets file, import GlobalUIAbilityContext.
import GlobalUIAbilityContext from '../util/ContextConfig';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    GlobalUIAbilityContext.setContext(this.context);
    // Other code
    // ...
  }
}

// Create a HandWritingComponent.ets file in the src/main/ets/ path to be used as a component.
import { HandwriteComponent, HandwriteController } from '@kit.Penkit';

@Component
struct HandWritingComponent {
  private controller: HandwriteController = new HandwriteController();
  private initPath: string = 'savePath';

  aboutToAppear() {
    if (canIUse('SystemCapability.Stylus.Handwrite')) {
      console.log('This device supports SystemCapability.Stylus.Handwrite');
    } else {
      console.log('This device does not support SystemCapability.Stylus.Handwrite');
    }
  }

  aboutToDisappear() {
    try {
      this.controller?.save(this.initPath);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      console.error(\`HandwriteController save error, the code is \${error.code}, the message is \${error.message}\`);
    }
  }

  build() {
    Row() {
      Column() {
        HandwriteComponent({
          handwriteController: this.controller,
          onInit: () => {
            try {
              this.controller?.load(this.initPath);
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              console.error(\`HandwriteController load error, the code is \${error.code}, the message is \${error.message}\`);
            }
          }
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}`;
  }
}