module Bench.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Unsafe (unsafePerformEffect)
import Data.Traversable (for_, intercalate)
import Performance.Minibench (BenchResult, benchWith', withUnits)


testApply :: forall m. MonadEffect m => Int -> m Unit
testApply n' = do
  arr <- liftEffect mkArr
  applyLoop (void <<< liftEffect <<< pushToArr arr) n'
  where
  applyLoop :: Monad m => (Int -> m Unit) -> Int -> m Unit
  applyLoop eff max = go (pure unit) 0
    where 
    go acc n | n == max = acc
    go acc n = go (acc <* eff n) (n + 1)


testBindRight :: forall m. MonadEffect m => Int -> m Unit
testBindRight n' = do
  arr <- liftEffect mkArr
  bindRightLoop (void <<< liftEffect <<< pushToArr arr) n'
  where
  bindRightLoop :: Monad m => (Int -> m Unit)  -> Int -> m Unit
  bindRightLoop eff max = go (pure unit) 0
    where 
    go acc n | n == max = acc
    go acc n = go (eff (max - n - 1) >>= const acc) (n + 1)


testBindLeft :: forall m. MonadEffect m => Int -> m Unit
testBindLeft n' = do
  arr <- liftEffect mkArr
  bindLeftLoop (void <<< liftEffect <<< pushToArr arr) n'
  where
  bindLeftLoop :: Monad m => (Int -> m Unit)  -> Int -> m Unit
  bindLeftLoop eff max = go (pure unit) 0
    where 
    go acc n | n == max = acc
    go acc n = go (acc >>= const (eff n)) (n + 1)


testMap :: forall m. MonadEffect m => Int -> m Unit
testMap n = do
  arr <- liftEffect mkArr
  res <- mapLoop n (liftEffect $ pushToArr arr 0)
  pure unit
  where
  mapLoop :: Monad m => Int -> m Int -> m Int
  mapLoop max i = 
    if max == 0 
      then i 
      else mapLoop (max - 1) (map (_ + 1) i)


main :: Effect Unit
main = do
  log "<details><summary>benchmark</summary>"
  log "| bench | type | n | mean | stddev | min | max |"
  log "| ----- | ---- | - | ---- | ------ | --- | --- |"
  bench 10 ">>=R" testBindRight testBindRight [100, 1000, 5000]
  bench 10 ">>=L" testBindLeft testBindLeft [100, 1000, 5000]
  bench 10 "map" testMap testMap [100, 1000, 5000]
  bench 10 "apply" testApply testApply [100, 1000, 5000]
  log "| - | - | - | - | - | - | - |"
  bench 2 ">>=R" testBindRight testBindRight [10000, 50000, 100000, 1000000]
  bench 2 ">>=L" testBindLeft testBindLeft [10000, 50000, 100000, 1000000]
  bench 2 "map" testMap testMap [10000, 50000, 100000, 1000000, 350000, 700000]
  bench 2 "apply" testApply testApply [10000, 50000, 100000, 1000000]
  log "</details>"

bench
  :: Int
  -> String
  -> (Int -> Effect Unit)
  -> (Int -> Aff Unit)
  -> Array Int
  -> Effect Unit
bench n name buildEffect buildAff vals = for_ vals \val -> do 
  logBench [name <> " build", "Eff", show val] $ benchWith' n \_ -> buildEffect val
  logBench' identity [name <> " build", "Aff", show val] $ benchWith' n \_ -> buildAff val
  let eff = liftEffect $ buildEffect val
  logBench [name <> " run", "Eff", show val] $ benchWith' n \_ -> unsafePerformEffect eff
  let aff = launchAff_ $ buildAff val
  logBench' identity [name <> " run", "Aff", show val] $ benchWith' n \_ -> unsafePerformEffect aff

logBench' :: (String -> String) -> Array String -> Effect BenchResult -> Effect Unit
logBench' f msg benchEffect = do
  res <- benchEffect
  let 
    logStr = intercalate " | " 
      $ append msg 
      $ map (f <<< withUnits) [res.mean, res.stdDev, res.min, res.max]
  log $  "| "  <> logStr <>  " |"

logBench :: Array String -> Effect BenchResult -> Effect Unit
logBench = logBench' \s -> "**" <> s <> "**"

foreign import data Arr :: Type -> Type
foreign import mkArr :: forall a. Effect (Arr a)
foreign import pushToArr :: forall a. Arr a -> a -> Effect a
foreign import log :: forall a. a -> Effect Unit

