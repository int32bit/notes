1. 删除所有的换行符和空格符

```bash
sed  -e ':a;N;s/\n//;s/ //g;ba' test.txt
```
or

```bash
cat test.txt | tr -d '\n '
```
