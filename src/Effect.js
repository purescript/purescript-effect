"use strict";

export var pureE = function (a) {
  return function () {
    return a;
  };
};

export var bindE = function (a) {
  return function (f) {
    return function () {
      return f(a())();
    };
  };
};

export var untilE = function (f) {
  return function () {
    while (!f());
  };
};

export var whileE = function (f) {
  return function (a) {
    return function () {
      while (f()) {
        a();
      }
    };
  };
};

export var forE = function (lo) {
  return function (hi) {
    return function (f) {
      return function () {
        for (var i = lo; i < hi; i++) {
          f(i)();
        }
      };
    };
  };
};

export var foreachE = function (as) {
  return function (f) {
    return function () {
      for (var i = 0, l = as.length; i < l; i++) {
        f(as[i])();
      }
    };
  };
};
