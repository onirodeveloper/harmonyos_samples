import '../../../commonDist/changehref.js';

const elements = document.querySelectorAll('a[rel="noopener noreferrer"]');
if (elements.length > 0) {
    window.addClickHref(elements);
}