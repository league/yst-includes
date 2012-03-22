#include <stdio.h>

int main()
{
  printf("Hello, world.\n");
  if(rand()%2 == 0) {
    printf("Yes\n");
  } else {
    printf("No\n");
  }
  return 0;
}

void frob(int x)
{
  // BEGIN EXAMPLE
  int y = x + 2;
  printf("%d %d\n", x, y);
  // END
}
