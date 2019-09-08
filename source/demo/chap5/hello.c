
#include <stdlib.h>

extern int foo1;
int a[2048];
int dummy = 10;

void main()
{
    char *m = malloc(1024);
	foo1 = 5;

    foo1_func();
    while (1) sleep(1000);
}

