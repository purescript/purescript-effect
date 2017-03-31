-- | This module defines types for effectful uncurried functions, as well as
-- | functions for converting back and forth between them.
-- |
-- | Traditionally, it has been difficult to give a PureScript type to
-- | JavaScript functions such as this one:
-- |
-- | ```javascript
-- | function logMessage(level, message) {
-- |   console.log(level + ": " + message);
-- | }
-- | ```
-- |
-- | In particular, note that `logMessage` performs effects immediately after
-- | receiving all of its parameters, so giving it the type `Data.Function.Fn2
-- | String String Unit`, while convenient, would effectively be a lie.
-- |
-- | Because there has been no way of giving such functions types, we generally
-- | resort to converting functions into the normal PureScript form (namely,
-- | a curried function returning an Eff action), and performing the
-- | marshalling in JavaScript, in the FFI module, like this:
-- |
-- | ```purescript
-- | -- In the PureScript file:
-- | foreign import logMessage :: forall eff.
-- |   String -> String -> Eff (console :: CONSOLE | eff) Unit
-- | ```
-- |
-- | ```javascript
-- | // In the FFI file:
-- | exports.logMessage = function(level) {
-- |   return function(message) {
-- |     return function() {
-- |       logMessage(level, message);
-- |     };
-- |   };
-- | };
-- | ```
-- |
-- | This method, unfortunately, turns out to be both tiresome and error-prone.
-- | This module offers an alternative solution. By providing you with:
-- |
-- |  * the ability to give the real `logMessage` function a PureScript type,
-- |    and
-- |  * functions for converting between this form and the normal PureScript
-- |    form,
-- |
-- | the FFI boilerplate is no longer needed. The previous example becomes:
-- |
-- | ```purescript
-- | -- In the PureScript file:
-- | foreign import logMessageImpl :: forall eff.
-- |   EffFn2 (console :: CONSOLE | eff) String String Unit
-- | ```
-- |
-- | ```javascript
-- | // In the FFI file:
-- | exports.logMessageImpl = logMessage
-- | ```
-- |
-- | You can then use `runEffFn2` to provide a nicer version:
-- |
-- | ```purescript
-- | logMessage :: forall eff.
-- |   String -> String -> Eff (console :: CONSOLE | eff) Unit
-- | logMessage = runEffFn2 logMessageImpl
-- | ```
-- |
-- | (note that this has the same type as the original `logMessage`).
-- |
-- | Effectively, we have reduced the risk of errors by moving as much code
-- | into PureScript as possible, so that we can leverage the type system.
-- | Hopefully, this is a little less tiresome too.
-- |
-- | Here's a slightly more advanced example. Here, because we are using
-- | callbacks, we need to use `mkEffFn{N}` as well.
-- |
-- | Suppose our `logMessage` changes so that it sometimes sends details of the
-- | message to some external server, and in those cases, we want the resulting
-- | `HttpResponse` (for whatever reason).
-- |
-- | ```javascript
-- | function logMessage(level, message, callback) {
-- |   console.log(level + ": " + message);
-- |   if (level > LogLevel.WARN) {
-- |     LogAggregatorService.post("/logs", {
-- |       level: level,
-- |       message: message
-- |     }, callback);
-- |   } else {
-- |     callback(null);
-- |   }
-- | }
-- | ```
-- |
-- | The import then looks like this:
-- | ```purescript
-- | foreign import logMessageImpl :: forall eff.
-- |  EffFn3 (http :: HTTP, console :: CONSOLE | eff)
-- |         String
-- |         String
-- |         (EffFn1 (http :: HTTP, console :: CONSOLE | eff)
-- |            (Nullable HttpResponse)
-- |            Unit)
-- |         Unit
-- | ```
-- |
-- | And, as before, the FFI file is extremely simple:
-- |
-- | ```javascript
-- | exports.logMessageImpl = logMessage
-- | ```
-- |
-- | Finally, we use `runEffFn{N}` and `mkEffFn{N}` for a more comfortable
-- | PureScript version:
-- |
-- | ```purescript
-- | logMessage :: forall eff.
-- |   String ->
-- |   String ->
-- |   (Nullable HttpResponse -> Eff (http :: HTTP, console :: CONSOLE | eff) Unit) ->
-- |   Eff (http :: HTTP, console :: CONSOLE | eff) Unit
-- | logMessage level message callback =
-- |   runEffFn3 logMessageImpl level message (mkEffFn1 callback)
-- | ```
-- |
-- | The general naming scheme for functions and types in this module is as
-- | follows:
-- |
-- | * `EffFn{N}` means, a curried function which accepts N arguments and
-- |   performs some effects. The first type argument is the row of effects,
-- |   which works exactly the same way as in `Eff`. The last type argument
-- |   is the return type. All other arguments are the actual function's
-- |   arguments.
-- | * `runEffFn{N}` takes an `EffFn` of N arguments, and converts it into the
-- |   normal PureScript form: a curried function which returns an Eff action.
-- | * `mkEffFn{N}` is the inverse of `runEffFn{N}`. It can be useful for
-- |   callbacks.
-- |

module Control.Monad.Eff.Uncurried where

import Control.Monad.Eff (kind Effect, Eff)

foreign import data EffFn1 :: # Effect -> Type -> Type -> Type
foreign import data EffFn2 :: # Effect -> Type -> Type -> Type -> Type
foreign import data EffFn3 :: # Effect -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn4 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn5 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn6 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn7 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn8 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn9 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffFn10 :: # Effect -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type

foreign import mkEffFn1 :: forall eff a r.
  (a -> Eff eff r) -> EffFn1 eff a r
foreign import mkEffFn2 :: forall eff a b r.
  (a -> b -> Eff eff r) -> EffFn2 eff a b r
foreign import mkEffFn3 :: forall eff a b c r.
  (a -> b -> c -> Eff eff r) -> EffFn3 eff a b c r
foreign import mkEffFn4 :: forall eff a b c d r.
  (a -> b -> c -> d -> Eff eff r) -> EffFn4 eff a b c d r
foreign import mkEffFn5 :: forall eff a b c d e r.
  (a -> b -> c -> d -> e -> Eff eff r) -> EffFn5 eff a b c d e r
foreign import mkEffFn6 :: forall eff a b c d e f r.
  (a -> b -> c -> d -> e -> f -> Eff eff r) -> EffFn6 eff a b c d e f r
foreign import mkEffFn7 :: forall eff a b c d e f g r.
  (a -> b -> c -> d -> e -> f -> g -> Eff eff r) -> EffFn7 eff a b c d e f g r
foreign import mkEffFn8 :: forall eff a b c d e f g h r.
  (a -> b -> c -> d -> e -> f -> g -> h -> Eff eff r) -> EffFn8 eff a b c d e f g h r
foreign import mkEffFn9 :: forall eff a b c d e f g h i r.
  (a -> b -> c -> d -> e -> f -> g -> h -> i -> Eff eff r) -> EffFn9 eff a b c d e f g h i r
foreign import mkEffFn10 :: forall eff a b c d e f g h i j r.
  (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Eff eff r) -> EffFn10 eff a b c d e f g h i j r

foreign import runEffFn1 :: forall eff a r.
  EffFn1 eff a r -> a -> Eff eff r
foreign import runEffFn2 :: forall eff a b r.
  EffFn2 eff a b r -> a -> b -> Eff eff r
foreign import runEffFn3 :: forall eff a b c r.
  EffFn3 eff a b c r -> a -> b -> c -> Eff eff r
foreign import runEffFn4 :: forall eff a b c d r.
  EffFn4 eff a b c d r -> a -> b -> c -> d -> Eff eff r
foreign import runEffFn5 :: forall eff a b c d e r.
  EffFn5 eff a b c d e r -> a -> b -> c -> d -> e -> Eff eff r
foreign import runEffFn6 :: forall eff a b c d e f r.
  EffFn6 eff a b c d e f r -> a -> b -> c -> d -> e -> f -> Eff eff r
foreign import runEffFn7 :: forall eff a b c d e f g r.
  EffFn7 eff a b c d e f g r -> a -> b -> c -> d -> e -> f -> g -> Eff eff r
foreign import runEffFn8 :: forall eff a b c d e f g h r.
  EffFn8 eff a b c d e f g h r -> a -> b -> c -> d -> e -> f -> g -> h -> Eff eff r
foreign import runEffFn9 :: forall eff a b c d e f g h i r.
  EffFn9 eff a b c d e f g h i r -> a -> b -> c -> d -> e -> f -> g -> h -> i -> Eff eff r
foreign import runEffFn10 :: forall eff a b c d e f g h i j r.
  EffFn10 eff a b c d e f g h i j r -> a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Eff eff r
