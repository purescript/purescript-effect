## Module Control.Monad.Eff

#### `Eff`

``` purescript
data Eff :: # ! -> * -> *
```

The `Eff` type constructor is used to represent _native_ effects.

See [Handling Native Effects with the Eff Monad](http://www.purescript.org/learn/eff/) for more details.

The first type parameter is a row of effects which represents the contexts in which a computation can be run, and the second type parameter is the return type.

##### Instances
``` purescript
instance functorEff :: Functor (Eff e)
instance applyEff :: Apply (Eff e)
instance applicativeEff :: Applicative (Eff e)
instance bindEff :: Bind (Eff e)
instance monadEff :: Monad (Eff e)
```

#### `Pure`

``` purescript
type Pure a = Eff () a
```

The `Pure` type synonym represents _pure_ computations, i.e. ones in which all effects have been handled.

The `runPure` function can be used to run pure computations and obtain their result.

#### `runPure`

``` purescript
runPure :: forall a. Pure a -> a
```

Run a pure computation and return its result.

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


