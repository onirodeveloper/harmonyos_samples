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

import { AICaptionComponent, AICaptionController, AICaptionOptions, AudioData } from '@kit.SpeechKit';
import type { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointType, GlobalInfoModel, Logger } from '@ohos/common';
import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { DescriptorWrapper } from '../../../viewmodel/DescriptorWrapper';

const TAG: string = '[CaptionComponent]';

@Builder
export function AICaptionBuilder(_$$: DescriptorWrapper) {
  CaptionComponent()
}

@Component
struct CaptionComponent {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @State isShown: boolean = true;
  isReading: boolean = false;
  componentWidth: number = 0;
  private captionOption?: AICaptionOptions;
  private controller: AICaptionController = new AICaptionController();

  aboutToAppear(): void {
    this.captionOption = {
      initialOpacity: DetailPageConstant.OPACITY_SMALL,
      onPrepared: () => {
        Logger.info(TAG, 'OnPrepared');
      },
      onError: (error: BusinessError) => {
        Logger.error(TAG, `AICaption component error. Error code: ${error.code}, message: ${error.message}`);
      },
    };
  }

  // Asynchronously read PCM file and write to buffer
  async readPcmAudio() {
    let fileData: Uint8Array;
    this.isReading = true;
    try {
      fileData = await getContext(this).resourceManager.getMediaContent($r('app.media.16k'));
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      Logger.error(TAG, `GetMediaContent error, the code is ${error.code}}, the message is ${error.message}`);
      this.isReading = false;
      return;
    }
    const bufferSize = 640;
    const byteLength = fileData.byteLength;
    let offset = 0;
    Logger.info(TAG, `Pcm data total bytes: ${byteLength.toString()}`);
    const startTime = new Date().getTime();
    while (offset < byteLength) {
      const nextOffset = offset + bufferSize;
      if (offset > byteLength) {
        this.isReading = false;
        return;
      }
      const arrayBuffer = fileData.buffer.slice(offset, nextOffset);
      const data = new Uint8Array(arrayBuffer);
      const audioData: AudioData = {
        data: data,
      };
      if (this.controller) {
        this.controller.writeAudio(audioData);
      }
      offset = offset + bufferSize;
      const waitTime = bufferSize / 32;
      await this.sleep(waitTime);
    }
    const endTime = new Date().getTime();
    this.isReading = false;
    Logger.info(TAG, `Audio play time: ${endTime - startTime}`);
  }

  sleep(time: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, time));
  }

  build() {
    Column({ space: DetailPageConstant.SPACE_LARGE }) {
      AICaptionComponent({
        isShown: this.isShown,
        controller: this.controller,
        options: this.captionOption,
      })
        .width(new BreakpointType({
          xs: $r('app.float.ai_caption_width'),
          sm: $r('app.float.ai_caption_width'),
          md: $r('app.float.ai_caption_width'),
          lg: $r('app.float.ai_caption_width'),
          xl: $r('app.float.ai_caption_width_xl'),
        }).getValue(this.globalInfoModel.currentBreakpoint))
        .height($r('app.float.ai_caption_height'))
        .margin({
          left: new BreakpointType({
            xs: DetailPageConstant.MARGIN_NEGATIVE_LARGER,
            sm: DetailPageConstant.MARGIN_NEGATIVE_LARGER,
            md: DetailPageConstant.MARGIN_NEGATIVE_LARGER,
            lg: DetailPageConstant.MARGIN_NEGATIVE_LARGER,
            xl: 0,
          }).getValue(this.globalInfoModel.currentBreakpoint)
        })

      Button($r('app.string.read_pcm_audio'))
        .backgroundColor($r('sys.color.background_secondary'))
        .height($r('app.float.button_height_normal'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          if (!this.isReading) {
            this.readPcmAudio();
          }
        })
    }
    .height($r('app.float.column_size_middle_one'))
    .margin({ top: $r('sys.float.padding_level10') })
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      this.componentWidth = newValue.width as number;
    })
  }
}