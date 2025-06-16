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
