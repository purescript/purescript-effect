module Effect.Class
  ( module MonadEffect
  , liftEffect
  ) where

import Effect (class MonadEffect, Effect)
import Effect (class MonadEffect) as MonadEffect
import Effect (liftEffect) as Effect
import Prim.TypeError (class Warn, Text)

liftEffect :: forall a m. MonadEffect m => Warn (Text "'Effect.Class.liftEffect' is deprecated, use Effect.liftEffect instead") => Effect a -> m a
liftEffect = Effect.liftEffect
