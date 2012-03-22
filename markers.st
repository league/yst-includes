
We can select by markers in the code.

~~~~ {.c include="selectlines.c" begin="// BEGIN" end="// END"}
~~~~

Testing begin only

~~~~ {.c include="marker1.c" begin="--{CUT}--"}
~~~~

Testing end only.

~~~~ {.c include="marker2.c" end="..STOP.."}
~~~~
