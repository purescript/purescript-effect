## Module Control.Monad.Eff.Unsafe

#### `unsafeInterleaveEff`

``` purescript
unsafeInterleaveEff :: forall eff1 eff2 a. Eff eff1 a -> Eff eff2 a
```

Change the type of an effectful computation, allowing it to be run in another context.

Note: use of this function can result in arbitrary side-effects.


