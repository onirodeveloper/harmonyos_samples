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
import '../../commonDist/changehref.js';

//liList
let liActive = 0;
const liList = Array.prototype.slice.call(
  document.getElementsByClassName('link-group-item'),
);
const designImg = document.getElementById('bg_mode_img_design');
const designImgListNormal = [
  './image/card_bg_3.png',
  './image/card_bg_4.png',
  './image/card_bg_5.png',
];

const designImgListWide = [
  './image/card_bg_3_wide.png',
  './image/card_bg_4_wide.png',
  './image/card_bg_5_wide.png',
];

const designImgListLarge = [
  './image/3_large.png',
  './image/4_large.png',
  './image/5_large.png',
];

liList.forEach((item, index) => {
  item.addEventListener('click', () => {
    liList[liActive].className = 'link-group-item';
    item.className = 'link-group-item active';
    liActive = index;
    setBottomBg();
  });
});

function setBottomBg() {
  if (window.innerWidth < 840) {
    designImg.src = designImgListNormal[liActive];
  } else if (window.innerWidth >= 840 && window.innerWidth < 1440) {
    designImg.src = designImgListWide[liActive];
  } else {
    designImg.src = designImgListLarge[liActive];
  }
}

window.onload = () => {
  setBottomBg();
};

let resizeTimeout;
window.onresize = () => {
  clearTimeout(resizeTimeout);
  resizeTimeout = setTimeout(() => {
    setBottomBg();
  }, 100);
};

const arrayA = Array.prototype.slice.call(
  document.getElementsByClassName('jump-link'),
);
window.addClickHref(arrayA);