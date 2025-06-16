function jump() {
  nativeActionData.jumpPage('component', 29, -1, 'TextToSpeech');
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

// 视频自然结束时重置按钮
video.addEventListener('ended', () => {
  playBtn.style.backgroundImage = 'url(./image/play_circle_fill.png)';
});
