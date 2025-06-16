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

export class TextToSpeechCodeGenerator implements CommonCodeGenerator {
  public generate(_attributes: OriginAttribute[]): string {
    return `import { textToSpeech } from '@kit.CoreSpeechKit';
import type { BusinessError } from '@kit.BasicServicesKit';
let ttsEngine: textToSpeech.TextToSpeechEngine;

@Component
struct TextToSpeechComponent {
  @State originalText: string = '古人学问无遗力，少壮工夫老始成；纸上得来终觉浅，绝知此事要躬行。';
  @State createCount: number = 0;
  @State result: boolean = false;
  @State voiceInfo: string = '';
  @State text: string = '';
  @State textContent: string = '';
  @State utteranceId: string = '123456';
  @State illegalText: string = '';
  @StorageLink('isPlaying') isPlaying: boolean = false;

  aboutToDisappear() {
    try {
      const isBusy = ttsEngine?.isBusy();
      if (isBusy) {
        ttsEngine?.stop();
        AppStorage.setOrCreate('isPlaying', false);
        ttsEngine?.shutdown();
      }
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      console.error(\`The ttsEngine invoke error, the code is \${error.code}, the message is \${error.message}\`);
    }
  }

  build() {
    Column({ space: 20 }) {
      TextArea({ text: this.originalText })
        .focusable(false)
        .backgroundColor(Color.Transparent)
        .margin({
          top: $r('sys.float.padding_level16'),
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16')
        })

      Row({ space: 40 }) {
        Button('', { type: ButtonType.Normal, stateEffect: true })
          .backgroundColor(Color.Transparent)
          // A picture of a play and a picture of a pause button needs to be added here.
          .backgroundImage(this.isPlaying?$r('app.media.pause'):$r('app.media.play_circle_fill'))
          .backgroundImagePosition(Alignment.Center)
          .onClick(() => {
            try {
              this.createByCallback();
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              console.error(\`CreateEngine error, the code is \${error.code}, the message is \${error.message}\`);
            }
          })
          .height('40vp')
          .width('40vp')

        Button('', { type: ButtonType.Normal, stateEffect: true })
          .backgroundColor(Color.Transparent)
          // A picture of a stop button needs to be added here.
          .backgroundImage($r('app.media.stop_circle'))
          .backgroundImagePosition(Alignment.Center)
          .onClick(() => {
            try {
              ttsEngine?.stop();
              ttsEngine?.shutdown();
            } catch (err) {
              const error: BusinessError = err as BusinessError;
              console.error(\`The ttsEngine invoke error, the code is \${error.code}, the message is \${error.message}\`);
            }
            AppStorage.setOrCreate('isPlaying', false);
          })
          .height('40vp')
          .width('40vp')
      }
      .margin({ top: $r('sys.float.padding_level8') })
      .height('40vp')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

   createByCallback() {
    let extraParam: Record<string, string> = { 'style': 'interaction-broadcast', 'locate': 'CN', 'name': 'EngineName' };
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };
    textToSpeech.createEngine(initParamsInfo,
      (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
        if (!err) {
          ttsEngine = textToSpeechEngine;
          this.createCount++;
          this.speak();
        } else {
          console.log('Fail to createEngine.');
        }
      });
  };

   speak() {
    let speakListener: textToSpeech.SpeakListener = {
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        console.log('onStart');
        AppStorage.setOrCreate('isPlaying', true);
      },
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        console.log('onComplete');
        AppStorage.setOrCreate('isPlaying', true);
      },
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        console.log('onStop');
        AppStorage.setOrCreate('isPlaying', false);
        ttsEngine?.shutdown();
      },
      onData(requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.log('onData');
      },
      onError(requestId: string, errorCode: number, errorMessage: string) {
        console.log('onError');
        AppStorage.setOrCreate('isPlaying', false);
        ttsEngine?.shutdown();
      }
    };
    ttsEngine?.setListener(speakListener);
    let extraParam: Record<string, string | number> = {
      'queueMode': 0,
      'speed': 1,
      'volume': 2,
      'pitch': 1,
      'languageContext': 'zh-CN',
      'audioType': 'pcm',
      'soundChannel': 3,
      'playType': 1
    }
    let speakParams: textToSpeech.SpeakParams = {
      requestId: '123456-a',
      extraParams: extraParam
    };
    ttsEngine?.speak(this.originalText, speakParams);
  };
}`;
  }
}