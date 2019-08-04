-- | This module defines types for effectful uncurried functions, as well as
-- | functions for converting back and forth between them.
-- |
-- | This makes it possible to give a PureScript type to JavaScript functions
-- | such as this one:
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
-- | One way to handle this would be to convert the function into the normal
-- | PureScript form (namely, a curried function returning an Effect action),
-- | and performing the marshalling in JavaScript, in the FFI module, like this:
-- |
-- | ```purescript
-- | -- In the PureScript file:
-- | foreign import logMessage :: String -> String -> Effect Unit
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
-- | foreign import logMessageImpl :: EffectFn2 String String Unit
-- | ```
-- |
-- | ```javascript
-- | // In the FFI file:
-- | exports.logMessageImpl = logMessage
-- | ```
-- |
-- | You can then use `runEffectFn2` to provide a nicer version:
-- |
-- | ```purescript
-- | logMessage :: String -> String -> Effect Unit
-- | logMessage = runEffectFn2 logMessageImpl
-- | ```
-- |
-- | (note that this has the same type as the original `logMessage`).
-- |
-- | Effectively, we have reduced the risk of errors by moving as much code into
-- | PureScript as possible, so that we can leverage the type system. Hopefully,
-- | this is a little less tiresome too.
-- |
-- | Here's a slightly more advanced example. Here, because we are using
-- | callbacks, we need to use `mkEffectFn{N}` as well.
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
-- | foreign import logMessageImpl
-- |  EffectFn3
-- |    String
-- |    String
-- |    (EffectFn1 (Nullable HttpResponse) Unit)
-- |    Unit
-- | ```
-- |
-- | And, as before, the FFI file is extremely simple:
-- |
-- | ```javascript
-- | exports.logMessageImpl = logMessage
-- | ```
-- |
-- | Finally, we use `runEffectFn{N}` and `mkEffectFn{N}` for a more comfortable
-- | PureScript version:
-- |
-- | ```purescript
-- | logMessage ::
-- |   String ->
-- |   String ->
-- |   (Nullable HttpResponse -> Effect Unit) ->
-- |   Effect Unit
-- | logMessage level message callback =
-- |   runEffectFn3 logMessageImpl level message (mkEffectFn1 callback)
-- | ```
-- |
-- | The general naming scheme for functions and types in this module is as
-- | follows:
-- |
-- | * `EffectFn{N}` means, an uncurried function which accepts N arguments and
-- |   performs some effects. The first N arguments are the actual function's
-- |   argument. The last type argument is the return type.
-- | * `runEffectFn{N}` takes an `EffectFn` of N arguments, and converts it into
-- |   the normal PureScript form: a curried function which returns an Effect
-- |   action.
-- | * `mkEffectFn{N}` is the inverse of `runEffectFn{N}`. It can be useful for
-- |   callbacks.
-- |

module Effect.Uncurried where

import Data.Function (($))
import Data.Monoid (class Monoid, class Semigroup, mempty, (<>))
import Effect (Effect)

foreign import data EffectFn1 :: Type -> Type -> Type
foreign import data EffectFn2 :: Type -> Type -> Type -> Type
foreign import data EffectFn3 :: Type -> Type -> Type -> Type -> Type
foreign import data EffectFn4 :: Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn5 :: Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn6 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn7 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn8 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn9 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type
foreign import data EffectFn10 :: Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type

foreign import mkEffectFn1 :: forall a r.
  (a -> Effect r) -> EffectFn1 a r
foreign import mkEffectFn2 :: forall a b r.
  (a -> b -> Effect r) -> EffectFn2 a b r
foreign import mkEffectFn3 :: forall a b c r.
  (a -> b -> c -> Effect r) -> EffectFn3 a b c r
foreign import mkEffectFn4 :: forall a b c d r.
  (a -> b -> c -> d -> Effect r) -> EffectFn4 a b c d r
foreign import mkEffectFn5 :: forall a b c d e r.
  (a -> b -> c -> d -> e -> Effect r) -> EffectFn5 a b c d e r
foreign import mkEffectFn6 :: forall a b c d e f r.
  (a -> b -> c -> d -> e -> f -> Effect r) -> EffectFn6 a b c d e f r
foreign import mkEffectFn7 :: forall a b c d e f g r.
  (a -> b -> c -> d -> e -> f -> g -> Effect r) -> EffectFn7 a b c d e f g r
foreign import mkEffectFn8 :: forall a b c d e f g h r.
  (a -> b -> c -> d -> e -> f -> g -> h -> Effect r) -> EffectFn8 a b c d e f g h r
foreign import mkEffectFn9 :: forall a b c d e f g h i r.
  (a -> b -> c -> d -> e -> f -> g -> h -> i -> Effect r) -> EffectFn9 a b c d e f g h i r
foreign import mkEffectFn10 :: forall a b c d e f g h i j r.
  (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Effect r) -> EffectFn10 a b c d e f g h i j r

foreign import runEffectFn1 :: forall a r.
  EffectFn1 a r -> a -> Effect r
foreign import runEffectFn2 :: forall a b r.
  EffectFn2 a b r -> a -> b -> Effect r
foreign import runEffectFn3 :: forall a b c r.
  EffectFn3 a b c r -> a -> b -> c -> Effect r
foreign import runEffectFn4 :: forall a b c d r.
  EffectFn4 a b c d r -> a -> b -> c -> d -> Effect r
foreign import runEffectFn5 :: forall a b c d e r.
  EffectFn5 a b c d e r -> a -> b -> c -> d -> e -> Effect r
foreign import runEffectFn6 :: forall a b c d e f r.
  EffectFn6 a b c d e f r -> a -> b -> c -> d -> e -> f -> Effect r
foreign import runEffectFn7 :: forall a b c d e f g r.
  EffectFn7 a b c d e f g r -> a -> b -> c -> d -> e -> f -> g -> Effect r
foreign import runEffectFn8 :: forall a b c d e f g h r.
  EffectFn8 a b c d e f g h r -> a -> b -> c -> d -> e -> f -> g -> h -> Effect r
foreign import runEffectFn9 :: forall a b c d e f g h i r.
  EffectFn9 a b c d e f g h i r -> a -> b -> c -> d -> e -> f -> g -> h -> i -> Effect r
foreign import runEffectFn10 :: forall a b c d e f g h i j r.
  EffectFn10 a b c d e f g h i j r -> a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Effect r

instance semigroupEffectFn1 :: Semigroup r => Semigroup (EffectFn1 a r) where
  append f1 f2 = mkEffectFn1 $ runEffectFn1 f1 <> runEffectFn1 f2

instance semigroupEffectFn2 :: Semigroup r => Semigroup (EffectFn2 a b r) where
  append f1 f2 = mkEffectFn2 $ runEffectFn2 f1 <> runEffectFn2 f2

instance semigroupEffectFn3 :: Semigroup r => Semigroup (EffectFn3 a b c r) where
  append f1 f2 = mkEffectFn3 $ runEffectFn3 f1 <> runEffectFn3 f2

instance semigroupEffectFn4 :: Semigroup r => Semigroup (EffectFn4 a b c d r) where
  append f1 f2 = mkEffectFn4 $ runEffectFn4 f1 <> runEffectFn4 f2

instance semigroupEffectFn5 :: Semigroup r => Semigroup (EffectFn5 a b c d e r) where
  append f1 f2 = mkEffectFn5 $ runEffectFn5 f1 <> runEffectFn5 f2

instance semigroupEffectFn6 :: Semigroup r => Semigroup (EffectFn6 a b c d e f r) where
  append f1 f2 = mkEffectFn6 $ runEffectFn6 f1 <> runEffectFn6 f2

instance semigroupEffectFn7 :: Semigroup r => Semigroup (EffectFn7 a b c d e f g r) where
  append f1 f2 = mkEffectFn7 $ runEffectFn7 f1 <> runEffectFn7 f2

instance semigroupEffectFn8 :: Semigroup r => Semigroup (EffectFn8 a b c d e f g h r) where
  append f1 f2 = mkEffectFn8 $ runEffectFn8 f1 <> runEffectFn8 f2

instance semigroupEffectFn9 :: Semigroup r => Semigroup (EffectFn9 a b c d e f g h i r) where
  append f1 f2 = mkEffectFn9 $ runEffectFn9 f1 <> runEffectFn9 f2

instance semigroupEffectFn10 :: Semigroup r => Semigroup (EffectFn10 a b c d e f g h i j r) where
  append f1 f2 = mkEffectFn10 $ runEffectFn10 f1 <> runEffectFn10 f2

instance monoidEffectFn1 :: Monoid r => Monoid (EffectFn1 a r) where
  mempty = mkEffectFn1 mempty

instance monoidEffectFn2 :: Monoid r => Monoid (EffectFn2 a b r) where
  mempty = mkEffectFn2 mempty

instance monoidEffectFn3 :: Monoid r => Monoid (EffectFn3 a b c r) where
  mempty = mkEffectFn3 mempty

instance monoidEffectFn4 :: Monoid r => Monoid (EffectFn4 a b c d r) where
  mempty = mkEffectFn4 mempty

instance monoidEffectFn5 :: Monoid r => Monoid (EffectFn5 a b c d e r) where
  mempty = mkEffectFn5 mempty

instance monoidEffectFn6 :: Monoid r => Monoid (EffectFn6 a b c d e f r) where
  mempty = mkEffectFn6 mempty

instance monoidEffectFn7 :: Monoid r => Monoid (EffectFn7 a b c d e f g r) where
  mempty = mkEffectFn7 mempty

instance monoidEffectFn8 :: Monoid r => Monoid (EffectFn8 a b c d e f g h r) where
  mempty = mkEffectFn8 mempty

instance monoidEffectFn9 :: Monoid r => Monoid (EffectFn9 a b c d e f g h i r) where
  mempty = mkEffectFn9 mempty

instance monoidEffectFn10 :: Monoid r => Monoid (EffectFn10 a b c d e f g h i j r) where
  mempty = mkEffectFn10 mempty
