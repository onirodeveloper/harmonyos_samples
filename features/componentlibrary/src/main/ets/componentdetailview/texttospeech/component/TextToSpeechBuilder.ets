/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apach License, Version 2.0 (the "License");
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
import { textToSpeech } from '@kit.CoreSpeechKit';
import { Logger } from '@ohos/common';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';
import type { TextToSpeechDescriptor } from '../viewmodel/TextToSpeechDescriptor';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import { ComponentDetailManager } from '../../../viewmodel/ComponentDetailManager';
import { AttributeChangeEnable } from '../../../viewmodel/ComponentDetailPageVM';

let ttsEngine: textToSpeech.TextToSpeechEngine;
const TAG: string = '[TextToSpeechComponent]';

@Component
struct TextToSpeechComponent {
  @Prop textToSpeechDescriptor: TextToSpeechDescriptor;
  @State originalText: string = '古人学问无遗力，少壮工夫老始成。纸上得来终觉浅，绝知此事要躬行。';
  @State text: string = '';
  @StorageLink('isPlaying') @Watch('changePlayMode') isPlaying: boolean = false;

  changePlayMode() {
    ComponentDetailManager.getInstance()
      .getDetailViewModel('TextToSpeech')?.sendEvent(new AttributeChangeEnable('speed', !this.isPlaying));
  }

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
      Logger.error(TAG, `The ttsEngine invoke error, the code is ${error.code}, the message is ${error.message}`);
    }
  }

  build() {
    Column({ space: DetailPageConstant.COMPONENT_GAP_SIZE }) {
      TextArea({ text: `${this.originalText}` })
        .focusable(false)
        .backgroundColor(Color.Transparent)
        .margin({
          top: $r('sys.float.padding_level16'),
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        })

      Row({ space: DetailPageConstant.COMPONENT_GAP_SIZE2 }) {
        Button() {
          if (this.isPlaying) {
            Image($r('app.media.pause'))
              .height($r('app.float.button_height_normal'))
              .width($r('app.float.button_height_normal'))
          } else {
            Image($r('app.media.play_circle_fill'))
              .height($r('app.float.button_height_normal'))
              .width($r('app.float.button_height_normal'))
          }
        }
        .height($r('app.float.button_height_normal'))
        .width($r('app.float.button_height_normal'))
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          try {
            this.createByCallback();
          } catch (err) {
            const error: BusinessError = err as BusinessError;
            Logger.error(TAG, `CreateEngine error, the code is ${error.code}, the message is ${error.message}`);
          }
        })

        Button() {
          Image($r('app.media.stop_circle'))
            .height($r('app.float.button_height_normal'))
            .width($r('app.float.button_height_normal'))
        }
        .height($r('app.float.button_height_normal'))
        .width($r('app.float.button_height_normal'))
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          try {
            ttsEngine?.stop();
            ttsEngine?.shutdown();
          } catch (err) {
            const error: BusinessError = err as BusinessError;
            Logger.error(TAG, `The ttsEngine invoke error, the code is ${error.code}, the message is ${error.message}`);
          }
          AppStorage.setOrCreate('isPlaying', false);
        })
      }
      .margin({ top: $r('sys.float.padding_level8') })
      .height($r('app.float.button_height_normal'))
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private createByCallback() {
    // The value of 'name' needs to be modified after each playback.
    const extraParam: Record<string, string> =
      { 'style': 'interaction-broadcast', 'locate': 'CN' };
    const initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam,
    };
    textToSpeech.createEngine(initParamsInfo,
      (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
        if (!err) {
          ttsEngine = textToSpeechEngine;
          this.speak();
        } else {
          Logger.error(TAG, `Fail to createEngine, because ${err.message}`);
        }
      });
  };

  private speak() {
    const speakListener: textToSpeech.SpeakListener = {
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        Logger.debug(TAG, `onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
        AppStorage.setOrCreate('isPlaying', true);
      },
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        Logger.info(TAG, `onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
        // Only playback completion is handled here, with no regard to stream file generation.
        // 'type === 1' means broadcast over situation.
        if (response.type === 1) {
          AppStorage.setOrCreate('isPlaying', false);
          ttsEngine?.stop();
        }
      },
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        Logger.debug(TAG, `onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
        AppStorage.setOrCreate('isPlaying', false);
        ttsEngine?.shutdown();
      },
      onError(requestId: string, errorCode: number, errorMessage: string) {
        Logger.error(TAG, `onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
        AppStorage.setOrCreate('isPlaying', false);
        ttsEngine?.shutdown();
      }
    };
    ttsEngine?.setListener(speakListener);
    const extraParam: Record<string, string | number> = {
      'queueMode': 0,
      'speed': this.textToSpeechDescriptor.speed,
      'volume': 1,
      'pitch': 1,
      'languageContext': 'zh-CN',
      'audioType': 'pcm',
      'soundChannel': 1,
      'playType': 1,
    };
    const speakParams: textToSpeech.SpeakParams = {
      requestId: '123456-a',
      extraParams: extraParam,
    };
    ttsEngine?.speak(this.originalText, speakParams);
  };
}

@Builder
export function TextToSpeechBuilder($$: DescriptorWrapper) {
  TextToSpeechComponent({ textToSpeechDescriptor: $$.descriptor as TextToSpeechDescriptor })
}