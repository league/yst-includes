# yst-includes

This is a Haskell program and a test suite for including code blocks
from external files in [yst](http://github.com/jgm/yst/) web sites. It
requires a version of yst that supports the `filter` directive in its
`config.yaml`:

~~~~
filter: runhaskell filter.hs
~~~~

Its simplest usage is like this:

    ~~~~ {.python include="hello.py"}
    This will be replaced by content of hello.py.
    ~~~~
