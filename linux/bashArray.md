# bash数组操作

bash支持两种数组，一种是索引数组，一种是关联数组

## 索引数组

数组的值类型是任意的，索引也未必一定要连续，当做列表理解更好

下面总结下索引数组，即列表：

### 1. 声明

```bash
declare -a a
```
### 2. 初始化

```bash
a=(1 2 3 4)
# OR
a=([0]=2 [3]=8) # 注意长度为2,不是4
```
### 3. 获取列表长度

```bash
size=${a[@]}
```
### 4. 追加元素
```bash
a+=(11 12 13 14)
```
### 5. 赋值
```
a[1]=9
```
### 6. 按索引读取
```
value=${a[0]} # 读取索引0的值
```
### 7. 删除某元素
```bash
unset a[0]
```
### 8. 清空数组
```bash
unset a
```
### 9. 切片
```bash
echo ${a[@]:1:3} # 从索引1开始的3个元素
```
### 10. 遍历
```bash
for i in ${a[@]}
do
	echo $i
done
```
## 关联数组

### 1. 声明
```bash
declare -A map
```
### 2. 初始化
```
map[key1]=value1
map[key2]=value2
# or
map=([key1]=value1 [key2]=value2)
```
### 3. 长度
```bash
size=${!map[@]}
```
### 4. 获取键集合
```bash
keyset=${!map[@]}
```
### 5. 获取值集合
```
values=${map[@]}
```
### 6. 遍历
```bash
for key in ${!map[$@]}
do
	echo $key:${map[$key]}
done
