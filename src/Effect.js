"use strict";


/*
A computation of type `Effect a` in runtime is represented by a function which when
invoked performs some effect and results some value of type `a`.

With trivial implementation of `Effect` we have an issue with stack usage, as on each `bind`
you create new function which increases size of stack needed to execute whole computation.
For example if you write `forever` recursively like this, stack will overflow:

``` purs
forever :: forall a b. Effect a -> Effect b
forever f = f *> forever f
```

Solution to the stack issue is to change runtime representation of Effect from function 
to some "free like structure" (Defunctionalization), for example if we were to write new
Effect structure which is stack safe we could do something like this:

``` purs
data EffectSafe a
  = Effect (Effect a)
  | Pure a
  | exists b. Map (b -> a) (EffectSafe b)
  | exists b. Apply (EffectSafe b) (EffectSafe (b -> a))
  | exists b. Bind (b -> EffectSafe a) (EffectSafe b)
```
implementing Functor Applicative and Monad instances would be trivial, and instead of
them constructing new function they create new node of EffectSafe tree structure
which then needs to be interpreted.


We could implement `EffectSafe` in PS but then to get safety benefits everyone should
start using it and doing FFI on such type will not be as easy as with `Effect` implemented
with just a function. If we just change runtime representation of the `Effect` that it would
brake all FFI related code, which we don't want to do.

So we need some way to achieve stack safety such that runtime representation is still a function.

hmmm...

In JS, function is an object, so we can set arbitrary properties on it. i.e. we can use function
as object, like look up some properties without invoking it. It means we can use function as
representation of `Effect`, as it was before, but set some properties on it, to be able get
benefits of the free-ish representation.

So we would assume an `Effect a` to be normal effectful function as before,
but it could also have `tag` property which could be 'PURE', 'MAP', 'APPLY' or 'BIND',
depending on the tag, we would expect certain properties to contain certain type of values:

``` js
Effect a
  = { Unit -> a }
  | { Unit -> a, tag: "PURE",   _0 :: a }
  | { Unit -> a, tag: "MAP",    _0 :: b -> a,        _1 :: Effect  b }
  | { Unit -> a, tag: "APPLY",  _0 :: Effect b,      _1 :: Effect (b -> a) }
  | { Unit -> a, tag: "BIND",   _0 :: b -> Effect a, _1 :: Effect  b }
```

Now hardest thing is to interpret this in stack safe way. but at first let's see
how `pureE` `mapE` `applyE` `bindE` `runPure` are defined:
*/

var PURE = "PURE";
var MAP = "MAP";
var APPLY = "APPLY";
var BIND = "BIND";
var APPLY_FUNC = "APPLY_FUNC";

exports.pureE = function (x) {
  return mkEff(PURE, x);
};

exports.mapE = function (f) {
  return function (effect) {
    return mkEff(MAP, f, effect);
  };
};

exports.applyE = function (effF) {
  return function (effect) {
    return mkEff(APPLY, effect, effF);
  };
};

exports.bindE = function (effect) {
  return function (f) {
    return mkEff(BIND, f, effect);
  };
};

/*

As you can see this function takes the `tag` and up to 2 values depending on the `tag`.
in here we create new named function which invokes runEff with itself
(we give it name so it's easy to identify such functions during debugging)
then we set `tag`, `_0` and `_1` properties on the function we just constructed
and return it so the result is basically an object which can also be invoked
and it then executes `runEff` with itself which tries to evaluate it without
increasing stack usage.

*/
function mkEff(tag, _0, _1) {
  var effect = function $effect() { return runEff($effect); };
  effect.tag = tag;
  effect._0 = _0;
  effect._1 = _1;
  return effect;
}

/*

So when this function is called it will take effect which must have the `tag` property on it.

we would set up some variables which are needed for safe evaluation:

* operations - this will be a type aligned sequence of `Operations` which looks like this:
  ``` purs
  Operation a b
    = { tag: "MAP",        _0 :: a -> b }
    | { tag: "APPLY",      _0 :: Effect a }
    | { tag: "APPLY_FUNC", _0 :: a -> b }
    | { tag: "BIND",       _0 :: a -> Effect b }
  ```
* effect - initially it's `inputEff` (argument of the `runEff`), it's basically tip of the tree,
  it will be then updated with other nodes while we are interpreting the structure.
* res - it will store results of invocations of effects which return results
* op - it will store current `Operation` which is popped from `operations`

if you look closely at Operation and Effect you would see that they have similar shape.
this nodes from `Effect` have same representation as `Operation`:

```
| { Unit -> a, tag: "MAP",    _0 :: b -> a,        _1 :: Effect  b }
| { Unit -> a, tag: "APPLY",  _0 :: Effect b,      _1 :: Effect (b -> a) }
| { Unit -> a, tag: "BIND",   _0 :: b -> Effect a, _1 :: Effect  b }
```
*/

function runEff(inputEff) {
  var operations = [];
  var effect = inputEff;
  var res;
  var op;
  effLoop: for (;;) {
    if (effect.tag !== undefined) {
      if (effect.tag === MAP || effect.tag === BIND || effect.tag === APPLY) {
        operations.push(effect);
        effect = effect._1 ;
        continue;
      }
      // here `tag === PURE`
      res = effect._0;
    } else {
      res = effect();
    }

    while ((op = operations.pop())) {
      if (op.tag === MAP) {
        res = op._0(res);
      } else if (op.tag === APPLY_FUNC) {
        res = op._0(res);
      } else if (op.tag === APPLY) {
        effect = op._0;
        operations.push({ tag: APPLY_FUNC, _0: res });
        continue effLoop;
      } else { // op.tag === BIND
        effect = op._0(res);
        continue effLoop;
      }
    }
    return res;
  }
}

exports.untilE = function (f) {
  return function () {
    while (!f());
    return {};
  };
};

exports.whileE = function (f) {
  return function (a) {
    return function () {
      while (f()) {
        a();
      }
      return {};
    };
  };
};

exports.forE = function (lo) {
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

exports.foreachE = function (as) {
  return function (f) {
    return function () {
      for (var i = 0, l = as.length; i < l; i++) {
        f(as[i])();
      }
    };
  };
};
