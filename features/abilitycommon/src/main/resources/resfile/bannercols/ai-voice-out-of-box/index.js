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
function jump() {
  nativeActionData.jumpPage('component', 28, -1, 'TextToSpeech');
}

let video = document.getElementById('voice-video');
let playBtn = document.getElementById('play-btn');
let stopBtn = document.getElementById('stop-btn');

playBtn.addEventListener('click', () => {
  if (video.paused) {
    video.play();
    playBtn.style.backgroundImage = 'url(./image/pause.png)';
  } else {
    video.pause();
    playBtn.style.backgroundImage = 'url(./image/play_circle_fill.png)';
  }
});

// 停止按钮点击事件
stopBtn.addEventListener('click', () => {
  video.pause();
  video.currentTime = 0;
  playBtn.style.backgroundImage = 'url(./image/play_circle_fill.png)';
});

// 视频自然结束时重置按�?
video.addEventListener('ended', () => {
  playBtn.style.backgroundImage = 'url(./image/play_circle_fill.png)';
});
