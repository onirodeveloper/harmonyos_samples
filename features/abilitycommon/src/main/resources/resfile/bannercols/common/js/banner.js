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
document.addEventListener('DOMContentLoaded', () => {
  const imgList = document.querySelectorAll('img');
  imgList.forEach((img, index) => {
    if (index >= 2) {
      img.loading = 'lazy';
    }
    if (img.complete) {
      img.classList.add('img-loaded');
    } else {
      img.addEventListener('load', () => img.classList.add('img-loaded'));
    }
  });
});

const footerImg = document.getElementsByClassName('footerImg')[0];
const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
const handleFooterImgChange = (e) => {
  footerImg.src = e.matches ? '../common/image/f_icon_dark.png' : '../common/image/f_icon.png';
};
handleFooterImgChange(darkModeQuery);
darkModeQuery.addEventListener('change', handleFooterImgChange);

window.checkPreview = () => {
  return false;
};