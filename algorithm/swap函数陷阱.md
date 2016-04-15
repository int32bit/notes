# swap函数陷阱

使用c实现一个交换两个数的函数，代码很简单：
```c
void swap(int *a, int *b)
{
    *a ^= *b;
    *b ^= *a;
    *a ^= *b;
}
```
只有3行代码，且没有引入中间变量，使用了位运算，效率高！

但一个明显的缺陷是没有检查空指针，于是代码修正为：
```c
void swap(int *a, int *b)
{
    if (a == NULL || b == NULL)
        return;
    *a ^= *b;
    *b ^= *a;
    *a ^= *b;
}
```
似乎这样就完美了？

看看以下代码：
```c
static int count = 0;
void permutation(int *a, int from, int to)
{
    if (from == to) {
        cout << ++count << ":";
        for (int i = 0; i <= to; ++i)
            cout << a[i] << " ";
        cout << endl;
        return;
    }
    for (int i = from; i <= to; ++i) {
        swap(&a[from], &a[i]);
        permutation(a, from + 1, to);
        swap(&a[from], &a[i]);
    }
}
```
以上代码功能很简单，使用递归的方式输出数组的全排列，核心算法肯定是没有问题的。可是运行以上代码，输出大量的0！！

*why ?*

答案在于swap函数还没有考虑当a，b是同一个指针的情况，当*a == b*时， *\*a ^= \*b*，结果必然为0，因此结果为*\*a == \*b == 0*,
因此正确的swap函数应该是这样的：
```c
void swap(int* a, int* b)
{
    if (a == NULL || b == NULL || a == b)
        return;
    *a ^= *b;
    *b ^= *a;
    *a ^= *b;
}
```
