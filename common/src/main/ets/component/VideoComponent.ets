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

@Component
export struct VideoComponent {
  @Prop mediaSrc: ResourceStr;
  @Prop autoPlay: boolean = true;
  @Prop loopPlay: boolean = true;
  @Prop clickPause: boolean = false;
  @Prop startVisibleRatio: number = 0.5;
  @State voiceControl: boolean = true;
  @State videoPauseShow: boolean = false;
  @State voiceShow: boolean = false;
  @State triggerValueReplace: number = 0;
  private exposureRatio: number[] = [0.0, this.startVisibleRatio, 1.0];
  private videoController: VideoController = new VideoController();
  private timeoutID = setTimeout(() => {
    this.voiceShow = false;
  }, 3000);

  private visibleAreaJudge(currentRatio: number) {
    if (currentRatio >= this.startVisibleRatio) {
      if (this.autoPlay) {
        this.showVoiceButton();
        this.videoPauseShow = false;
        this.videoController.start();
      }
    } else {
      this.voiceShow = true;
      this.videoPauseShow = true;
      this.videoController.pause();
    }
  }

  private showVoiceButton() {
    this.voiceShow = true;
    clearTimeout(this.timeoutID);
    this.timeoutID = setTimeout(() => {
      this.voiceShow = false;
    }, 3000);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Video({ src: this.mediaSrc, controller: this.videoController })
          .muted(this.voiceControl)
          .objectFit(ImageFit.Contain)
          .controls(false)
          .onFinish(() => {
            if (this.loopPlay) {
              this.videoController.start();
            } else {
              this.videoPauseShow = true;
              this.videoController.pause();
            }
          })
          .onTouch(() => {
            this.showVoiceButton();
          })
          .onClick(() => {
            if (this.clickPause) {
              this.videoPauseShow = true;
              this.videoController.pause();
            }
          })
          .onVisibleAreaChange(this.exposureRatio, (isVisible: boolean, currentRatio: number) => {
            this.visibleAreaJudge(currentRatio);
          })
        if (this.voiceShow) {
          SymbolGlyph(this.voiceControl ? $r('sys.symbol.speaker_slash_fill') : $r('sys.symbol.speaker_fill'))
            .fontSize($r('app.float.voice_font_size'))
            .fontColor([Color.White])
            .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.triggerValueReplace)
            .onClick(() => {
              this.triggerValueReplace++;
              this.voiceControl = !this.voiceControl;
            })
        }
      }

      if (this.videoPauseShow) {
        SymbolGlyph($r('sys.symbol.play_circle'))
          .fontSize($r('app.float.video_pause_font_size'))
          .fontColor([Color.White])
          .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.triggerValueReplace)
          .onClick(() => {
            this.triggerValueReplace++;
            this.videoPauseShow = false;
            this.videoController.start();
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}