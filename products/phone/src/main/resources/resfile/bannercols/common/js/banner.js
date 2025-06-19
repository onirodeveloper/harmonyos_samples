const footerImg = document.getElementsByClassName('footerImg')[0];
const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
const handleFooterImgChange = (e) => {
  footerImg.src = e.matches ? '../common/image/f_icon_dark.png' : '../common/image/f_icon.png';
};
handleFooterImgChange(darkModeQuery);
darkModeQuery.addEventListener('change', handleFooterImgChange);
window.addEventListener('beforeunload', () => {
  darkModeQuery.removeEventListener('change', handleFooterImgChange);
});

window.checkPreview = () => {
  return false;
};