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

import '../../common/dist/jquery.js';
function getArticleJson() {
  return $.getJSON('../../common/config/articleUrlConfig.json')
    .done(function (data) {
      return data;
    });
}

function getGiteeJson() {
  return $.getJSON('../../common/config/giteeUrlConfig.json')
    .done(function (data) {
      return data;
    });
}

(function () {
  const elements = document.querySelectorAll('a[rel="noopener noreferrer"]');
  Promise.all([getArticleJson(), getGiteeJson()])
    .then((res) => {
      const articleUrlConfig = res[0];
      const giteeUrlConfig = res[1];
      elements.forEach((item) => {
        let hrefValue = item.getAttribute('href');
        let type = 0;
        if (!hrefValue) {
          return;
        }
        if (hrefValue.includes('article')) {
          const key = hrefValue.split('_').slice(1).join('_');
          item.addEventListener('click', (event) => {
            event.preventDefault();
            if (articleUrlConfig[key].includes(articleUrlConfig.main_domain)) {
              type = 1;
            }
            nativeActionData.webSheet(articleUrlConfig[key], type);
          });
        } else if (hrefValue.includes('gitee')) {
          const key = hrefValue.split('_').slice(1).join('_');
          item.addEventListener('click', (event) => {
            event.preventDefault();
            if (giteeUrlConfig[key].includes(articleUrlConfig.main_domain)) {
              type = 1;
            }
            nativeActionData.webSheet(giteeUrlConfig[key], type);
          });
        }
      });
    });
})();
