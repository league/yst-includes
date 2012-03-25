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

But it also supports some other parameters, such as `first` and `last`
to specify a range of lines.

    ~~~~ {.c include="hello.c" first="5" last="10"}
    ~~~~

Or, you can use `begin` and `end` to specify strings that will turn on
(and off, respectively) inclusion of lines from the file. For example,
if `frob.c` contains:

    void frob(int x)
    {
      // BEGIN EXAMPLE
      int y = x + 2;
      printf("%d %d\n", x, y);
      // END
    }

    float grab()
    {
      // BEGIN EXAMPLE
      printf("OK\n");
      return 3.14;
      // END
    }

Then the following code block:

    ~~~~ {.c include="frob.c" begin="// BEGIN" end="// END"}
    ~~~~

will produce:

      int y = x + 2;
      printf("%d %d\n", x, y);
      printf("OK\n");
      return 3.14;

Finally, we support a parameter `prompt` that specifies a regular
expression meant to help with highlighting command-line interfaces.
The text that matches the regular expression is highlighted with `span
class="prompt"` and the rest of that line is highlighted with `span
class="cmd"`. For example:

    ~~~~ {prompt="liucs:.*\\\$"}
    liucs:~/cs643\$ cd a4/build
    liucs:~/cs643/a4/build\$ make
    [...]
    32 bytes (32 B) copied, 0.000254176 s, 126 kB/s
    cat vdi-header-2 >>vdi-header
    cat vdi-header diskc.img >diskc.vdi
    cp diskc.vdi /mnt/host
    rm libc/entry.o
    liucs:~/cs643/a4/build\$
    ~~~~
