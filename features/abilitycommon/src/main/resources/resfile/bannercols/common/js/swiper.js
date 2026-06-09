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
const swiper = document.getElementsByClassName('card-wrap')[0];
const pointElements = document.getElementsByClassName('swiper-point');
const points = Array.from(pointElements);

let startX = 0;
let startY = 0;
let scrollX = 0;
let current = 0;
let scrollDir;
let startTime;
let maxDeltaX = 0;
let isDragging = false;

function handleStart(e) {
  const client = e.touches ? e.touches[0] : e;
  startTime = Date.now();
  startX = client.clientX;
  startY = client.clientY;
  swiper.style.transition = 'none';

  isDragging = true;

  // 鼠标事件动态绑定移动和结束监听
  if (!e.touches) {
    document.addEventListener('mousemove', handleMove);
    document.addEventListener('mouseup', handleEnd);
  }
}

function handleMove(e) {
  // 只在拖动时处�?
  if (!isDragging) {
    return;
  }

  const client = e.touches ? e.touches[0] : e;
  const deltaX = client.clientX - startX;
  const deltaY = client.clientY - startY;

  if (!scrollDir) {
    scrollDir = Math.abs(deltaX) > Math.abs(deltaY) ? 'x' : 'y';
  }

  if (scrollDir === 'x') {
    // 横向滚动阻止默认
    if (e.cancelable) {
        e.preventDefault();
    }
    maxDeltaX = Math.abs(deltaX) > Math.abs(maxDeltaX) ? deltaX : maxDeltaX;
    scrollX = client.clientX;
    swiper.style.transform = `translateX(${current * -100
      }%) translateX(${deltaX}px)`;
  }
}

function handleEnd(e) {
  if (!isDragging) {
    return;
  }
  if (e.cancelable) {
    e.preventDefault();
  }
  const endTime = Date.now();
  swiper.style.transition = 'transform 0.4s ease';

  if (scrollDir === 'x') {
    const delta = scrollX - startX;
    const isFlick = endTime - startTime < 200;
    const isReverseSwipe = Math.abs(maxDeltaX) - Math.abs(delta) > 20;

    if (isFlick) {
      if (Math.abs(delta) > 10) {
        updateCurrent(delta > 0 ? -1 : 1);
      }
    } else if (isReverseSwipe) {
      // 取消滑动
    } else {
      if (Math.abs(delta) > 50) {
        updateCurrent(delta > 0 ? -1 : 1);
      }
    }

    swiper.style.transform = `translateX(${current * -100}%)`;
    setPointSelect(current);
  }

  // 重置状�?
  scrollDir = undefined;
  maxDeltaX = 0;
  isDragging = false;

  // 移除鼠标监听
  if (!e.touches) {
    document.removeEventListener('mousemove', handleMove);
    document.removeEventListener('mouseup', handleEnd);
  }
}

function updateCurrent(step) {
  const newIndex = current + step;
  current = Math.max(0, Math.min(newIndex, swiper.children.length - 1));
}

swiper.addEventListener('touchstart', handleStart);
swiper.addEventListener('touchmove', handleMove);
swiper.addEventListener('touchend', handleEnd);

swiper.addEventListener('mousedown', handleStart);

points.forEach((item, index) => {
  item.addEventListener('click', () => {
    current = index;
    // 重置swiper的位置以匹配动画开始前的位置（尽管这里可能看起来多余，但保持一致性是个好习惯�?
    swiper.style.transform = `translateX(${current * -100}%) translateX(0px)`;
    // 设置过渡效果并触发动�?
    swiper.style.transition = 'transform 0.4s ease';
    requestAnimationFrame(() => {
      swiper.style.transform = `translateX(${current * -100}%)`;
    });

    setPointSelect(index);
  });
});

function setPointSelect(currentIndex) {
  points.forEach((item, index) => {
    item.classList.toggle('swiper-point-selected', index === currentIndex);
  });
}