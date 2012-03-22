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
