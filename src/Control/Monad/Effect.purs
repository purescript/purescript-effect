module Control.Monad.Effect
  ( Effect
  , untilE, whileE, forE, foreachE
  ) where

import Control.Applicative (class Applicative, liftA1)
import Control.Apply (class Apply)
import Control.Bind (class Bind)
import Control.Monad (class Monad, ap)

import Data.Functor (class Functor)
import Data.Unit (Unit)

-- | The `Effect` type constructor is used to represent _native_ effects.
-- |
-- | See [Handling Native Effects with the Effect Monad](http://www.purescript.org/learn/eff/)
-- | for more details.
-- |
-- | The type parameter denotes the return type of running the effect.
foreign import data Effect :: Type -> Type

instance functorEffect :: Functor Effect where
  map = liftA1

instance applyEffect :: Apply Effect where
  apply = ap

instance applicativeEffect :: Applicative Effect where
  pure = pureE

foreign import pureE :: forall a. a -> Effect a

instance bindEffect :: Bind Effect where
  bind = bindE

foreign import bindE :: forall a b. Effect a -> (a -> Effect b) -> Effect b

instance monadEffect :: Monad Effect

-- | Loop until a condition becomes `true`.
-- |
-- | `untilE b` is an effectful computation which repeatedly runs the effectful
-- | computation `b`, until its return value is `true`.
foreign import untilE :: Effect Boolean -> Effect Unit

-- | Loop while a condition is `true`.
-- |
-- | `whileE b m` is effectful computation which runs the effectful computation
-- | `b`. If its result is `true`, it runs the effectful computation `m` and
-- | loops. If not, the computation ends.
foreign import whileE :: forall a. Effect Boolean -> Effect a -> Effect Unit

-- | Loop over a consecutive collection of numbers.
-- |
-- | `forE lo hi f` runs the computation returned by the function `f` for each
-- | of the inputs between `lo` (inclusive) and `hi` (exclusive).
foreign import forE :: Int -> Int -> (Int -> Effect Unit) -> Effect Unit

-- | Loop over an array of values.
-- |
-- | `foreachE xs f` runs the computation returned by the function `f` for each
-- | of the inputs `xs`.
foreign import foreachE :: forall a. Array a -> (a -> Effect Unit) -> Effect Unit
