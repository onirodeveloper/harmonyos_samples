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

export class AICaptionCodeGenerator implements CommonCodeGenerator {
  public generate(_attributes: OriginAttribute[]): string {
    return `import { AICaptionComponent, AICaptionController, AICaptionOptions, AudioData } from '@kit.SpeechKit';
import type { BusinessError } from '@kit.BasicServicesKit';

@Component
struct CaptionComponent {
  @State isShown: boolean = true;
  isReading: boolean = false;
  private captionOption?: AICaptionOptions;
  private controller: AICaptionController = new AICaptionController();
  componentWidth:number = 0;

  aboutToAppear(): void {
    this.captionOption = {
      initialOpacity: 0.2,
      onPrepared: () => {
        console.log('OnPrepared');
      },
      onError: (error: BusinessError) => {
        console.error('AICaption component error.');
      }
    }
  }

  async readPcmAudio() {
    let fileData: Uint8Array;
    this.isReading = true;
    try {
      fileData = await getContext(this).resourceManager.getMediaContent($r('app.media.16k'));
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      console.error(\`GetMediaContent error, the code is \${error.code}, the message is \${error.message}\`);
      this.isReading = false;
      return;
    }
    // Here you need a voice file in PCM format, one that can clearly convey the text.
    const bufferSize = 640;
    const byteLength = fileData.byteLength;
    let offset = 0;
    const startTime = new Date().getTime();
    while (offset < byteLength) {
      let nextOffset = offset + bufferSize
      if (offset > byteLength) {
        this.isReading = false;
        return;
      }
      const arrayBuffer = fileData.buffer.slice(offset, nextOffset);
      let data = new Uint8Array(arrayBuffer);
      const audioData: AudioData = {
        data: data
      }

      if (this.controller) {
        this.controller.writeAudio(audioData);
      }
      offset = offset + bufferSize;
      const waitTime = bufferSize / 32;
      await this.sleep(waitTime);
    }
    const endTime = new Date().getTime();
    this.isReading = false;
  }

  sleep(time: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, time));
  }

  build() {
    Column({ space: 20 }) {
      AICaptionComponent({
        isShown: this.isShown,
        controller: this.controller,
        options: this.captionOption
      })
        .width(240)
        .height(100)
        .margin({ left: -95 })

        Button('读取PCM音频')
          .backgroundColor($r('sys.color.background_secondary'))
          .height(40)
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .onClick(() => {
            if (!this.isReading) {
              this.readPcmAudio();
            }
          })
      }
      .width(240)
      .height(200)
      .margin({ top: 40 })
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.componentWidth = newValue.width as number;
      })
  }
}`;
  }
}