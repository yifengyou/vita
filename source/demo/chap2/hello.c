#include <stdio.h>

extern int foo2;

int main(int argc, char *argv[])
{
    foo2 = 5;
    foo2_func(50);
    return 0;
}

