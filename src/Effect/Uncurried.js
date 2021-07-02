"use strict";

export var mkEffectFn1 = function mkEffectFn1(fn) {
  return function(x) {
    return fn(x)();
  };
};

export var mkEffectFn2 = function mkEffectFn2(fn) {
  return function(a, b) {
    return fn(a)(b)();
  };
};

export var mkEffectFn3 = function mkEffectFn3(fn) {
  return function(a, b, c) {
    return fn(a)(b)(c)();
  };
};

export var mkEffectFn4 = function mkEffectFn4(fn) {
  return function(a, b, c, d) {
    return fn(a)(b)(c)(d)();
  };
};

export var mkEffectFn5 = function mkEffectFn5(fn) {
  return function(a, b, c, d, e) {
    return fn(a)(b)(c)(d)(e)();
  };
};

export var mkEffectFn6 = function mkEffectFn6(fn) {
  return function(a, b, c, d, e, f) {
    return fn(a)(b)(c)(d)(e)(f)();
  };
};

export var mkEffectFn7 = function mkEffectFn7(fn) {
  return function(a, b, c, d, e, f, g) {
    return fn(a)(b)(c)(d)(e)(f)(g)();
  };
};

export var mkEffectFn8 = function mkEffectFn8(fn) {
  return function(a, b, c, d, e, f, g, h) {
    return fn(a)(b)(c)(d)(e)(f)(g)(h)();
  };
};

export var mkEffectFn9 = function mkEffectFn9(fn) {
  return function(a, b, c, d, e, f, g, h, i) {
    return fn(a)(b)(c)(d)(e)(f)(g)(h)(i)();
  };
};

export var mkEffectFn10 = function mkEffectFn10(fn) {
  return function(a, b, c, d, e, f, g, h, i, j) {
    return fn(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)();
  };
};

export var runEffectFn1 = function runEffectFn1(fn) {
  return function(a) {
    return function() {
      return fn(a);
    };
  };
};

export var runEffectFn2 = function runEffectFn2(fn) {
  return function(a) {
    return function(b) {
      return function() {
        return fn(a, b);
      };
    };
  };
};

export var runEffectFn3 = function runEffectFn3(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function() {
          return fn(a, b, c);
        };
      };
    };
  };
};

export var runEffectFn4 = function runEffectFn4(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function() {
            return fn(a, b, c, d);
          };
        };
      };
    };
  };
};

export var runEffectFn5 = function runEffectFn5(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function(e) {
            return function() {
              return fn(a, b, c, d, e);
            };
          };
        };
      };
    };
  };
};

export var runEffectFn6 = function runEffectFn6(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function(e) {
            return function(f) {
              return function() {
                return fn(a, b, c, d, e, f);
              };
            };
          };
        };
      };
    };
  };
};

export var runEffectFn7 = function runEffectFn7(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function(e) {
            return function(f) {
              return function(g) {
                return function() {
                  return fn(a, b, c, d, e, f, g);
                };
              };
            };
          };
        };
      };
    };
  };
};

export var runEffectFn8 = function runEffectFn8(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function(e) {
            return function(f) {
              return function(g) {
                return function(h) {
                  return function() {
                    return fn(a, b, c, d, e, f, g, h);
                  };
                };
              };
            };
          };
        };
      };
    };
  };
};

export var runEffectFn9 = function runEffectFn9(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function(e) {
            return function(f) {
              return function(g) {
                return function(h) {
                  return function(i) {
                    return function() {
                      return fn(a, b, c, d, e, f, g, h, i);
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
};

export var runEffectFn10 = function runEffectFn10(fn) {
  return function(a) {
    return function(b) {
      return function(c) {
        return function(d) {
          return function(e) {
            return function(f) {
              return function(g) {
                return function(h) {
                  return function(i) {
                    return function(j) {
                      return function() {
                        return fn(a, b, c, d, e, f, g, h, i, j);
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
};
