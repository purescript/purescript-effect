module Control.Monad.Effect.Unsafe where

import Control.Monad.Effect (Effect)

-- | Run an effectful computation.
-- |
-- | *Note*: use of this function can result in arbitrary side-effects.
foreign import unsafePerformEffect :: forall a. Effect a -> a
