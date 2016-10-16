# elm-tail-recursion

SUPRISE! elm has runtime exceptions!
Don't let anybody tell you differently.
Rather than pretend they don't exist,
this library hopes to mitigate their occurrences.

## Crash

The most obvious offender is [`crash`][crash].
I mean it says it right in the name.
It also says it right in the type `String -> a`.
Which means that given a string, you can produce ANY value in all of elm.
Sounds remarkable like null...

[`crash`][crash] is not magic, and so it can't do what it actually says.
Otherwise, we could have all our implementations be one line with a bunch of types.

```elm
type Google
  = ...

google : Google
google =
  Debug.crash "Oh look, we made Google!"
```

What [`crash`][crash] actually does is throw a runtime exception.
But, [`crash`][crash] is not the only way to throw a runtime exception.
At least, there are other ways at the time of writing.

## Tail Recursion

A much sneaker way is to write a recursive function that isn't tail recursive and use it with certain arguments that cause js to blow the stack.
It's sneaky in the fact that, we do this all the time, but rarely recognize it.
Mostly, we get away with it most of the time because our input values usually keep the recursion bounded.
But words like "mostly" and "usually" are indicators of hard to find bugs.
You might also think js is to blame for this runtime exception.
The fact of the matter is, elm generated the js that caused the runtime exception.

Luckily, all is not lost!
elm is smart enough to compile tail recursive functions into js that will not blow the stack.
The solution is to always write tail recursive functions.

We can help a bit by extracting the recursive part to a function that guarantees not to blow the stack.
You may still run out of memory; but, that's a separate concern that this library doesn't handle.
You also may still have unbounded recursion; but, again, that's a separate concern that this library doesn't handle.

The takeaway is that recursion is not your enemy and neither is unbounded recursion.
Non-tail recursive recursion is your enemy—currently anyway.

[crash]: http://package.elm-lang.org/packages/elm-lang/core/4.0.5/Debug#crash
