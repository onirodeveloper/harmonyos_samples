import '../../commonDist/changehref.js';

const arrayA = Array.prototype.slice.call(
  document.getElementsByClassName('jump-link'),
);
window.addClickHref(arrayA);