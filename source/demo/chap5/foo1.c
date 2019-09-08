
extern int foo2;
int foo1 = 10;
int dummy = 20;

void foo1_func()
{
    int a = foo2;
    int b = dummy;
    int c = foo1;

    foo2_func();
}
