## 1. 删除所有的换行符和空格符

```bash
sed  -e ':a;N;s/\n//;s/ //g;ba' test.txt
```
or

```bash
cat test.txt | tr -d '\n '
```

## 2. spark on hive

* spark编译了hive
* 必须把hive-site.xml 复制到spark配置目录中
* 必须把hive使用的元数据库的驱动加入到SPARK_CLASSPATH中
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe17+08pqcvLq16DX8ZklIYcYBVZBoodiWKyBZdK2d+iJvvzYfWi8kbuWhZT6H9cGeOn3VfBrdVAgVISSS0zjGvNzc1ndzxFwl/AcG7k2F8dt3KQiCSMXckCBO2nOhW9EcQU88NHlISUlXT5hacps0Gl/nhDeO9ayYRL+Kf40/gmtuSo3CcoFlxPin2Q3cxnCULjJjBVzLpXSnOoPqBf8BRh3Se8b4adHh6cIcvuwevbXzByalj3YC12KlSEM0vtC93CmD3YyQUV/kJuzZt4PwOM0YavI36m7grFvysZjnOCMESiF65nMH5gxgca/SpNkMWvttdDzI2/+FP99zMFPh bupt@controller

##  shell 笔记

### 1. 获取当前shell的环境变量,按行输出
`xargs -0` 或者 `--null` 表示分隔符为`0`字符, `-n`表示每次传参数的最大个数
```bash
cat /proc/$$/environ | xargs -0 -n 1
cat /proc/$$/environ | tr  '\0' '\n'
```
### 2. 设置动态库路径
```bash
export LD_LIBRARY_PATH=/opt/myapp/lib
```
### 3. let算术操作
支持 `++` `--` `+` `-` `*` `/` `**` `&` `|`等
```bash
a=$((5 ** 5)) # a = 3125, 等价a = let 5 ** 5
echo "scale=3; 10 / 3" | bc # 浮点数
```
### 4. bash正则表达式匹配
```bash
[[ 'a5a' =~ [a-zA-Z][0-9][a-z] ]] && echo "YES" || echo "NO"
# 注意 =~ 后面的正则表达式不能用引号
```
### 5. 重定向
`>&` 实际复制了文件描述符, `ls >dirlist 2>&1` 与 `ls 2>&1 >dirlist` 不一样
### 6. 关联数组

* `declare -a a` 把变量a声明为索引数组
* `declare -A a` 把变量a声明为关联数组
* `${a[@]}`获取所有的值， `${!a[@]}` 获取所有的键
### 7. exec & source
* source: 在当前进程中执行参数文件中的各个命令，而不是另起子进程
* exec: 以当前命令替换shell的上下文，并不起子进程,使用这一命令时任何现有环境都将会被清除。 exec在对文件描述符进行操作的时候，也只有在这时，exec不会覆盖你当前的 shell 环境。
`\(command1;command2\)\`: 将命令置于新进程，继承父进程所有文件描述符

### 8. 关联数组 
```bash
declare -A map
map[key]=value
map=([key1]=value1 [key2]=value2)
keyset: ${!map[@]}
values: ${map[@]}
map[count]=0
let map[count]++
```
### 9. tput stty
### 10. 通过引用子shell保留空格和回车，使用引号
`out="$(ls)"`
### 11. read -n 字符个数 -s 禁止回显 -p 提示符 -t 时间 -d 分隔符
### 12. true命令可能会生成一个新进程，使用冒号效率更高
### 13. 字段分隔符、参数分隔符`IFS`
```bash
IFS=','
line='1,2,3,4,5'
for i in line
do
 echo $i
done
```
### 14. for 循环
```bash
# 迭代
for i in list
do
	echo $i
done
# range
for i in {1..50}
do
	echo $i
done
# c 风格
for((i = 0; i <= 50; ++i))
do
	echo $i
done
```
### 15. cat
```bash 
cat - a >out # 从标准输入流输入内容插入a中
cat -s 过滤多余空行
```
### 16. script & scriptreplay
### 17. find 命令
```bash
#删除所有的swp文件
find . -maxdepth 1 -type f -name "*.swp" -delete
# 将10天前的文件复制到OLD目录
find . -maxdepth 1 -type -f  -mtime +10 -name ".txt" -exec cp {} OLD \;
```
### 18. xargs 命令
```bash
echo -n "split:split:split:split" | xargs -d : -n 2
split split
split split
#output
split split
split split
# 统计c代码行数
find . -maxdepth 1 -type f -name ".c" -print0 | xargs -0 wc -l 
# 注意print0 和-0 表示以null作为分隔符，防止文件名包括空格回车造成错误
```
### 19. tr命令
```bash
# 小写转化大写
echo "heLLo" | tr 'a-z' 'A-Z'
echo "heLLo" | tr '[:lower:]' ''[:upper:]'
# 空格转化为回车
echo "1 2 3 4" | tr ' ' '\n'
# 删除数字
echo "abcd123dd" | tr -d '0-9' # abcddd
# 保留数字
echo "abcd123dd" | tr -d -c '0-9' # 123
# 压缩字符
echo "aaabbbccc" | tr -s 'ab' # abccc
# 求和
echo '1 2 3 4 5' | echo $[ $(tr ' ' '+') ]
```
### 20. 文件校验
```bash
# 产生校验
md5sum test.txt >test.md5
# 校验
md5sum -c test.md5
```
### 21. 文件加密crypt gpg base64
### 22. sort
```bash
# 默认按字典序排列
echo "3 2 1 13 11 12" |tr ' ' '\n' | sort | tr '\n' ' ' # 1 11 12 13 2 3
# 使用-n按大小排序
echo "3 2 1 13 11 12" |tr ' ' '\n' | sort -n | tr '\n' ' ' # 1 2 3 11 12 13
# 使用-r表示逆序
# 检查文件是否排序
sort -C test1 && echo "sorted" || echo "unsorted"
# 使用-k指定哪个列作为键
# -b 忽略前导空白行
# -m 把已排好序的文件归并
```
### 23. uniq
```bash
# 注意该文件必须保证是已排好序的文件
# 过滤重复行
echo "1 2 2 3 3 3" | tr ' ' '\n' | uniq # 1 2 3 
# 只输出唯一行
echo "1 2 2 3 3 3" | tr ' ' '\n' | uniq -u # 1
# 统计重复次数
echo "a b b c c c c" | tr ' ' '\n' | uniq -c # 1 a 2 b 4 c
# 输出重复行
echo "a b b c c c c" | tr ' ' '\n' | uniq -d # b c
```
### 24. mktemp 创建临时文件
### 25. 切分文件名
```bash
# 获取文件扩展名
${file#*.}
# 或者文件名
${file%.*}
```
### 26. 批量重名名文件
```bash
# 把*.JPG 重命名为*.jpg
rename *.JPG *.jpg
# 将文件名的空格替换为_
rename 's/ /_/g' *
# 转化文件大小写
rename 'y/a-z/A-Z/' *
```
### 27. look单词查找
### 28. 数组追加
```bash
a=() # 声明一个空数组
a+=(1 2) # 追加1 2 到数组a中
```
### 29. 并行进程加速命令执行
```bash
PIDS=()
for i in {1..50}
do
	echo $i >>out &
	PIDS+=("$!") # $!表示最后一个后台进程pid，追加到PIDS数组中
done
wait ${PIDS[@]}
```
### 30. 文件交集、差集
```bash
# 两个文件必须是排好序的
comm A.txt b.txt
# 第1列包含只在A文件（A的差集），2列包含只在B文件（B 的差集），
# 第3列包含A、B相同的行（A、B的交集）
# -1 -2 -3 分布表示删除第1,2,3列
```
### 31. 文件差异和修补
```bash
# 查看文件差异
diff a.txt b.txt
# 打补丁
diff a.txt b.txt >patch
patch a.txt < patch
# 取消补丁
patch -p1 a.txt <patch
# 生成目录
diff -Naur d1 d2
# -r 递归 -N：缺失文件视为空文件 -u：生成一体化输出 -a 将所有文件视为文本文件
```
### 32. head & tail
```bash
head -n num
# num 为正数，则只输出前num行，默认为10,若num为负数，则输出前num行以外的行
tail -n num
tail -f file
#当进程PID停止，tail自动退出
tail -f  --pid $PID file
```
### 33. 只列出目录的方法
```bash
ls -d */ # 不能少/
ls -F | grep "/$"
ls -l | grep "^d"
find . -maxdepth 1 -type d -print
```
### 34. grep
```bash
# -o 只输出匹配的文本部分
# -c 统计匹配行数（不是次数)
# 求匹配次数
grep -o '[0-9]+' | wc -l
# 打印行号 -n
# -b打印偏移量，常常和-o连用
# -l 只打印匹配的文件列表，-L打印不匹配的文件列表
# -R 递归
# -i 忽略大小写
# 匹配多个样式， -e
grep -e 'pattern1' -e 'pattern2'
# 指定文件
# 只搜索c或者cpp文件
grep --include *.{c,cpp} 
# --exclude "README.md" 不搜索该文件
# -Z 输出以0作为文件名终结符,与-l结合使用
grep -Zlr "test" * 
# -q 不输出任何东西，匹配返回0,不匹配返回1
# -A -B -C 输出上下文-A向后输出n行，-B向前输出n行，-C 向前向后输出n行
```
### 35. cut
```bash
# -f 指定列， 与--complement结合，输出不包括这些列的所有列 -f 3,5打印第3,5列
# -f 3- 打印从第3列开始的所有列
# -c字符 -b字节 -f字段
```
### 36. sed
### 37. awk
```bash
# -v 传递外部变量
# getline读取一行，尤其在BEGIN块使用过滤头部信息
# getline var，var保存内容，若调用不带参数的getline，则可以使用$0-$9访问
# -F列分隔符
```