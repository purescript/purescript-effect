# Important notice

This module should not yet be depended on, it is for the upcoming 0.7 compiler release.

# Module Documentation

## Module Control.Monad.Eff

#### `Eff`

``` purescript
data Eff :: # ! -> * -> *
```

The `Eff` type constructor is used to represent _native_ effects.

See [Handling Native Effects with the Eff Monad](https://github.com/purescript/purescript/wiki/Handling-Native-Effects-with-the-Eff-Monad) for more details.

The first type parameter is a row of effects which represents the contexts in which a computation can be run, and the second type parameter is the return type.

#### `Pure`

``` purescript
type Pure a = forall e. Eff e a
```

The `Pure` type synonym represents _pure_ computations, i.e. ones in which all effects have been handled.

The `runPure` function can be used to run pure computations and obtain their result.

#### `runPure`

``` purescript
runPure :: forall a. Pure a -> a
```

Run a pure computation and return its result.

Note: since this function has a rank-2 type, it may cause problems to apply this function using the `$` operator. The recommended approach
is to use parentheses instead.

#### `functorEff`

``` purescript
instance functorEff :: Functor (Eff e)
```


#### `applyEff`

``` purescript
instance applyEff :: Apply (Eff e)
```


#### `applicativeEff`

``` purescript
instance applicativeEff :: Applicative (Eff e)
```


#### `bindEff`

``` purescript
instance bindEff :: Bind (Eff e)
```


#### `monadEff`

``` purescript
instance monadEff :: Monad (Eff e)
```


#### `untilE`

``` purescript
untilE :: forall e. Eff e Boolean -> Eff e Unit
```

Loop until a condition becomes `true`.

`untilE b` is an effectful computation which repeatedly runs the effectful computation `b`,
until its return value is `true`.

#### `whileE`

``` purescript
whileE :: forall e a. Eff e Boolean -> Eff e a -> Eff e Unit
```

Loop while a condition is `true`.

`whileE b m` is effectful computation which runs the effectful computation `b`. If its result is
`true`, it runs the effectful computation `m` and loops. If not, the computation ends.

#### `forE`

``` purescript
forE :: forall e. Number -> Number -> (Number -> Eff e Unit) -> Eff e Unit
```

Loop over a consecutive collection of numbers.

`forE lo hi f` runs the computation returned by the function `f` for each of the inputs
between `lo` (inclusive) and `hi` (exclusive).

#### `foreachE`

``` purescript
foreachE :: forall e a. Array a -> (a -> Eff e Unit) -> Eff e Unit
```

Loop over an array of values.

`foreach xs f` runs the computation returned by the function `f` for each of the inputs `xs`.


## Module Control.Monad.Eff.Unsafe

#### `unsafeInterleaveEff`

``` purescript
unsafeInterleaveEff :: forall eff1 eff2 a. Eff eff1 a -> Eff eff2 a
```

Change the type of an effectful computation, allowing it to be run in another context.

Note: use of this function can result in arbitrary side-effects.



