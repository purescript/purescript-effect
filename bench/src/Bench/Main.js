"use strict";

exports.mkArr = function(){
  return { count: 0 };
};

exports.pushToArr = function(xs) {
  return function() {
    return function() {
      xs.count += 1;
      return xs;
    };
  };
};

exports.log = function(x) {
  return function(){
    // eslint-disable-next-line
    console.log(x);
  };
};