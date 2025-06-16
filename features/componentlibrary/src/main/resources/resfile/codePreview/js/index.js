const code = document.getElementById('code');
const pre = document.getElementsByTagName('pre')[0];
const link = document.getElementsByTagName('link')[0];
const codeContainer = document.getElementsByTagName('code')[0];
const LIGHT = 1;
const DARK = 0;
const UP = 'up';
const DOWN = 'down';

let lastScrollTop = 0;
code.addEventListener('scroll', handleScroll);

function toFullScreen() {
    code.style.overflowY = 'scroll';
    code.style.paddingLeft = '16px';
    code.style.paddingRight = '16px';
    pre.style.paddingTop = '100px';
    pre.style.paddingBottom = '70px';
}

function toSmallScreen() {
    code.scrollTo({top: 0});
    code.style.overflowY = 'hidden';
    pre.style.paddingTop = '12px';
    pre.style.paddingBottom = '0px';
    code.style.paddingLeft = '0px';
    code.style.paddingRight = '0px';
}

function changeColorMode(colorMode) {
    link.href = colorMode === LIGHT ? './dist/light.css' : './dist/dark.css';
}

function codeToHtml(codeParam, colorMode) {
    codeContainer.innerHTML = codeParam;
    delete codeContainer.dataset.highlighted;
    if (colorMode !== undefined) {
        changeColorMode(colorMode);
    }
    window.hljs.highlightAll();
}

function showLandscapeView(breakPoint) {
    code.scrollTo({top: 0});
    pre.style.paddingTop = breakPoint === 'sm' ? '60px' : '100px';
    code.style.paddingLeft = breakPoint === 'sm' ? '56px' : '12px';
}

function showLandscapeFloatView(breakPoint) {
    code.scrollTo({top: 0});
    pre.style.paddingTop = breakPoint === 'sm' ? '60px' : '100px';
    code.style.paddingLeft = breakPoint === 'sm' ? '16px' : '12px';
}

function showPortraitView() {
    code.scrollTo({top: 0});
    code.style.paddingLeft = '16px';
    pre.style.paddingTop = '100px';
}

function handleScroll() {
    const scrollTop = code.scrollTop;
    if (scrollTop > lastScrollTop) {
        scrollManager.updateScrollDirection(DOWN);
    } else if (scrollTop < lastScrollTop) {
        scrollManager.updateScrollDirection(UP);
    }
    lastScrollTop = scrollTop;
}

function changeHeightStyle() {
    document.getElementById('code').style.height = '100%';
}

function removeHeightStyle() {
    document.getElementById('code').style.height = 'auto';
}