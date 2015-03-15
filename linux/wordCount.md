# 使用bash关联数组统计单词

从bash 4开始支持关联数组，使用前需要声明，即
```bash
declare -A map
map[key1]=value1
map[key2]=value2
map=([key1]=value1 [key2]=value2)
# 获取keys
keys=${!map[@]}
# 获取values
values=${map[@]}
```
利用关联数组，很容易实现单词统计,源码文件[wordCount.sh](src/wordCount.sh)
```bash
#!/bin/bash
if [[ $# -lt 1 ]]
then
	echo "Usage: $0 <filename>"
	exit 1
fi
file=$1
declare -A count
for word in $(grep -P -o '\b\w+\b' $file)
do
	let count[$word]++
done
for word in ${!count[@]}
do
	printf "%-14s%s\n" $word ${count[$word]}
done
```
使用方法
```bash
./wordCount.sh filename
```
或者从标准流中使用，如
```bash
echo "Hello World! GoodBye World!" | ./wordCount.sh -
```
输出为
```
Hello         1
World         2
GoodBye       1
```

