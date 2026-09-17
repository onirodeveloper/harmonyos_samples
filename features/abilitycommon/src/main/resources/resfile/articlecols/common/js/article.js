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
import '../../../commonDist/changehref.js';

const elements = document.querySelectorAll('a[rel="noopener noreferrer"]');
if (elements.length > 0) {
    window.addClickHref(elements);
}

const showMoreItems = document.querySelectorAll('[data-show-more="true"]');
showMoreItems.forEach((toggle) => {
    const topicBody = toggle.closest('.topicbody');
    const toggleParagraph = toggle.closest('p');
    if (!topicBody || !toggleParagraph) {
        return;
    }

    const contentAfterToggle = [];
    let next = toggleParagraph.nextElementSibling;
    while (next) {
        contentAfterToggle.push(next);
        next = next.nextElementSibling;
    }

    const setExpanded = (expanded) => {
        contentAfterToggle.forEach((element) => {
            element.hidden = !expanded;
        });
        toggle.textContent = expanded ? 'Show less' : 'Show more';
        toggle.setAttribute('aria-expanded', expanded.toString());
    };

    setExpanded(false);
    toggle.addEventListener('click', () => {
        setExpanded(toggle.getAttribute('aria-expanded') !== 'true');
    });
    toggle.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            setExpanded(toggle.getAttribute('aria-expanded') !== 'true');
        }
    });
});

const foldButtons = document.querySelectorAll('.foldButton');
foldButtons.forEach((button) => {
    button.textContent = 'Show more';
    if (button.dataset.englishFoldBound === 'true') {
        return;
    }
    button.dataset.englishFoldBound = 'true';
    button.addEventListener('click', () => {
        const screen = button.closest('.screen');
        if (!screen || !screen.classList.contains('fold')) {
            return;
        }
        screen.classList.replace('fold', 'expand');
        const divider = button.nextElementSibling;
        button.remove();
        divider?.remove();
    });
});
