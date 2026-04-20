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