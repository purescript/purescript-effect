"use strict";

export var unsafePerformEffect = function (f) {
  return f();
};
