"use strict";

exports.mkArr = function(){
  return [];
};

exports.unArr = function(xs){
  return xs.slice(0);
};

exports.pushToArr = function(xs) {
  return function(x) {
    return function() {
      xs.push(x);
      return x;
    };
  };
};

exports.assert = function(isOk) {
  return function(msg) {
    return function() {
      if (isOk == false) {
        throw new Error("assertion failed: " + msg);
      };
    };
  };
};

exports.naturals = function(n) {
  var res = [];
  for (var index = 0; index < n; index++) {
    res[index] = index;
  }
  return res;
};

exports.log = function(x) {
  return function(){
    console.log(x)
  }
};


exports.time = function(x) {
  return function(){
    console.time(x)
  }
};


exports.timeEnd = function(x) {
  return function(){
    console.timeEnd(x)
  }
};
