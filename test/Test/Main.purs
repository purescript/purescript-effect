module Test.Main where

import Prelude

import Effect (Effect)
import Control.Apply (lift2)

testLift2 :: Effect Unit
testLift2 = do
  arr <- mkArr
  res <- (pushToArr arr 1) `lift2 (+)` (pushToArr arr 2)
  res' <- (pure 1) `lift2 (+)` (pure 2)
  assert ([1, 2] == unArr arr) "lift2 1/3"
  assert (3 == res') "lift2 2/3"
  assert (3 == res) "lift2 3/3"


testApply :: Int -> Effect Unit
testApply n' = do
  arr <-  mkArr
  applyLoop (void <<< pushToArr arr) n'
  assert (naturals n' == unArr arr) $ "apply " <> show n'
  where
  applyLoop eff max = go (pure unit) 0
    where 
    go acc n | n == max = acc
    go acc n = go (acc <* eff n) (n + 1)



testBindRight :: Int -> Effect Unit
testBindRight n' = do
  arr <-  mkArr
  bindRightLoop (void <<< pushToArr arr) n'
  assert (naturals n' == unArr arr) $ "bind right " <> show n'
  where
  bindRightLoop eff max = go (pure unit) 0
    where 
    go acc n | n == max = acc
    go acc n = go (eff (max - n - 1) >>= const acc) (n + 1)


testBindLeft :: Int -> Effect Unit
testBindLeft n' = do
  arr <-  mkArr
  bindLeftLoop (void <<< pushToArr arr) n'
  assert (naturals n' == unArr arr) $ "bind left " <> show n'
  where
  bindLeftLoop eff max = go (pure unit) 0
    where 
    go acc n | n == max = acc
    go acc n = go (acc >>= const (eff n)) (n + 1)


testMap :: Int -> Effect Unit
testMap n = do
  arr <- mkArr
  res <- mapLoop n (pushToArr arr 0)
  assert (res == n) $ "map " <> show n
  assert ([0] == unArr arr) $ "map" 
  where
  mapLoop max i = 
    if max == 0 
      then i 
      else mapLoop (max - 1) (map (_ + 1) i)


main :: Effect Unit
main = do
  test "testLift2" $ testLift2
  test "testBindRight" $ testBindRight 1000000
  test "testBindLeft" $ testMap 1000000
  test "testMap" $ testMap 5000000
  test "testApply" $ testApply 1000000
  where
  test msg eff = do
    time msg
    eff
    timeEnd msg


foreign import data Arr :: Type -> Type


foreign import mkArr :: forall a. Effect (Arr a)
foreign import pushToArr :: forall a. Arr a -> a -> Effect a
foreign import assert :: Boolean -> String -> Effect Unit
foreign import log :: forall a. a -> Effect Unit
foreign import unArr :: forall a. Arr a -> Array a
foreign import naturals :: Int -> Array Int

foreign import time :: String -> Effect Unit
foreign import timeEnd :: String -> Effect Unit
