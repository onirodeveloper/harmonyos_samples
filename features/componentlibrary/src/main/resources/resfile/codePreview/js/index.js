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
const code = document.getElementById('code');
const pre = document.getElementsByTagName('pre')[0];
const themeStyle = document.getElementById('theme-style');
const codeContainer = document.getElementsByTagName('code')[0];
const LIGHT = 1;
const DARK = 0;
const UP = 'up';
const DOWN = 'down';
let currentColorMode = LIGHT;
let lightCSS = '';
let darkCSS = '';

fetch('./commonDist/light.css').then(function(r) { return r.text(); }).then(function(t) {
    lightCSS = t;
    if (currentColorMode === LIGHT) {
        themeStyle.textContent = lightCSS;
    }
});
fetch('./commonDist/dark.css').then(function(r) { return r.text(); }).then(function(t) {
    darkCSS = t;
    if (currentColorMode === DARK) {
        themeStyle.textContent = darkCSS;
    }
});

let lastScrollTop = 0;
const throttleScroll = throttle(handleScroll);
code.addEventListener('scroll', throttleScroll);

function throttle(func, wait = 100) {
    let timeoutId;
    return function (...args) {
        if (!timeoutId) {
            func.apply(this, args);
            timeoutId = setTimeout(() => {
                timeoutId = null;
            }, wait);
        }
    };
}
function toFullScreen() {
    code.style.overflowY = 'scroll';
    pre.style.paddingTop = '60px';
    pre.style.paddingBottom = '70px';
}

function toSmallScreen() {
    code.scrollTo({top: 0});
    code.style.overflowY = 'hidden';
    pre.style.paddingTop = '12px';
    pre.style.paddingBottom = '0px';
}

function changeColorMode(colorMode) {
    if (colorMode === currentColorMode) return;
    currentColorMode = colorMode;
    themeStyle.textContent = colorMode === LIGHT ? lightCSS : darkCSS;
}

function codeToHtml(codeParam, colorMode) {
    codeContainer.textContent = codeParam;
    delete codeContainer.dataset.highlighted;
    if (colorMode !== undefined && colorMode !== currentColorMode) {
        changeColorMode(colorMode);
    }
    window.hljs.highlightAll();
}

function showLandscapeView(breakPoint) {
    code.scrollTo({top: 0});
}

function showLandscapeFloatView(breakPoint) {
    code.scrollTo({top: 0});
}

function showPortraitView() {
    code.scrollTo({top: 0});
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

if (window._pendingCP) {
    codeToHtml(window._pendingCP.c, window._pendingCP.m);
    window._pendingCP = null;
}