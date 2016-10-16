module TailRecursion exposing (recurse)

{-|
# Table of Contents

1. [Functions](#functions)
1. [Example](#example)
  1. [Mutual Recursion](#mutual-recursion)
  1. [Direct Recursion](#direct-recursion)
  1. [Using recurse](#using-recurse)
  1. [Nota Bene](#nota-bene)
  1. [Put it All Together](#put-it-all-together)

## Functions
@docs recurse

## Example

A simple example is in order.
When writing mutually recursive functions,
elm compiles to code that can blow the stack.
Mutual recursion isn't the only place we can get a benefit here,
so don't read too much into the example.

### Mutual Recursion
For instance, the following functions can blow the stack:

```elm
even : Int -> Bool
even n =
  case n of
    0 ->
      True
    _ ->
      odd (n - 1)

odd : Int -> Bool
odd n =
  case n of
    0 ->
      False
    _ ->
      even (n - 1)
```

These functions are fine for small positive values.
But if we apply a large `Int` (like `1000000`), elm will throw a runtime exception.

This example is trivial and contrived for a reason.
There are multiple ways to solve this problem better, but that's not the purpose of it.
The purpose is to show that even a simple pair of mutually recursive functions can cause runtime errors with elm.

### Direct Recursion

We can write this tail recursively by just inlining the body of both mutual recursions.

```elm
even : Int -> Bool
even n =
  case n of
    0 ->
      True
    _ ->
      case (n - 1) of
        0 ->
          False
        _ ->
          even ((n - 1) - 1)

odd : Int -> Bool
odd n =
  case n of
    0 ->
      False
    _ ->
      case (n - 1) of
        0 ->
          True
        _ ->
          odd ((n - 1) - 1)
```

After a bit of cleanup, it's even understandable!

```elm
even : Int -> Bool
even n =
  case n of
    0 ->
      True
    1 ->
      False
    _ ->
      even (n - 2)

odd : Int -> Bool
odd n =
  case n of
    0 ->
      False
    1 ->
      True
    _ ->
      odd (n - 2)
```

A very clean and elegant solution, but a solution that removes the inherent mutual recursion of the original.
Every problem we face with mutual recursion isn't always so easily changed.
Perhaps even more important is that converting mutual recursion to direct recursion can't always happen.

### Using [`recurse`][recurse]

There's another solution we could have arrived at though.
One that keeps the mutual recursion but protects ourselves from blowing the stack.
If we extract the base and inductive cases out,
we can use [`recurse`][recurse] instead.

We need to supply a function `(a -> Result b a)` and `a` to [`recurse`][recurse].
The `a` will be `Int`, as that's the input type of `even`/`odd`.
The `b` will be `Bool`, as that's the return type of `even`/`odd`.

So we need to create a function `Int -> Result Bool Int`.
Let's look at `even` first.
If the `Int` is `0`, we're done, we know what value to return—`True`.
If the `Int` is anything else, we're not done.
We need to recurse with the predecessor.

Similar logic works for the `odd` step.

```elm
evenStep : Int -> Result Bool Int
evenStep n =
  case n of
    0 ->
      Err True
    _ ->
      Ok (n - 1)

oddStep : Int -> Result Bool Int
oddStep n =
  case n of
    0 ->
      Err False
    _ ->
      Ok (n - 1)
```

### Nota Bene

It's important to notice that we're not doing any actual recursion here.
We're just converting `Int`s into `Result Bool Int`.
I think most people will agree that it's much easier to understand and test non-recursive functions
than recursive functions.

### Put it All Together

Now that we have our "recursive" functions, we need to put them to use with [`recurse`][recurse].
For the `even` function, we want to follow the ideas of our original implementation.
We first take an even step, and then we take an odd step.
For the `odd` function, we first take an odd step, and then we take an even step
The functions almost write themselves.

```elm
even : Int -> Bool
even =
  recurse <| \n ->
    evenStep n `Result.andThen` oddStep

odd : Int -> Bool
odd =
  recurse <| \n ->
    oddStep n `Result.andThen` evenStep
```

Notice that we can lean on the our good friend `Result.andThen`.
All of our functions that we know and use are still applicable here.
We don't need to attempt to learn some new abstractions to use [`recurse`][recurse]

Now if we apply `1000000` to `even`, we'll actually get a value, rather than a runtime exception!

[recurse]: #recurse
-}

{-|
If you have a non-tail recursive function,
use this function to ensure it won't blow the stack.

Some explanation for how this works.

Thanks to purity and fast-and-loose reasoning,
we have exactly one way to implement this function.

The only way to get a `b` is to apply an `a` to `a -> Result b a`.
If the result of application is `Ok a`,
we still don't have a `b` and must apply this new `a` to `a -> Result a b`.
At some point we get a value `Err b`, and thus we can finally end the recursion.
-}
recurse : (a -> Result b a) -> a -> b
recurse f x =
    case f x of
        Ok x ->
            recurse f x

        Err y ->
            y
