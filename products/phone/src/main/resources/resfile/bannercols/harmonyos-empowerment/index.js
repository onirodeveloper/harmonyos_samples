import '../../articlecols/common/dist/jquery.js';
function getArticleJson() {
  return $.getJSON('../../articlecols/common/config/articleUrlConfig.json')
    .done(function (data) {
      return data;
    });
}
function getGiteeJson() {
  return $.getJSON('../../articlecols/common/config/giteeUrlConfig.json')
    .done(function (data) {
      return data;
    });
}
const btnList = Array.from(document.getElementsByClassName('catalog-item'));
Promise.all([getArticleJson(), getGiteeJson()])
  .then((res) => {
    const articleUrlConfig = res[0];
    const giteeUrlConfig = res[1];
    btnList.forEach((item) => {
      let hrefValue = item.getAttribute('url');
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
