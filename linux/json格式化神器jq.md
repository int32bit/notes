#  json 格式化神器jq

### 官方简介
>
**jq is a lightweight and flexible command-line JSON processor.**
>
jq is like sed for JSON data - you can use it to slice and filter and map and transform structured data with the same ease that sed, awk, grep and friends let you play with text.
>
jq is written in portable C, and it has zero runtime dependencies. You can download a single binary, scp it to a far away machine of the same type, and expect it to work.
>
jq can mangle the data format that you have into the one that you want with very little effort, and the program to do so is often shorter and simpler than you’d expect.

### 安装

ubuntu自带软件包，直接使用`apt-get`安装

```sh
sudo apt-get install -y jq
```
### 使用

`jq`和`awk`、`sed`、`grep`类似先过滤或者转换，即使用方法为

```sh
jq [options...] filter [files...]
```
下面以[test.txt](static/test.txt) json文件作为demo，内容如下:

```json
[{"name":"Mary", "age":26, "sponse":{"name":"Jim", "age":27}, "children":[{"name":"Lucy", "age":8}, {"name":"Lily", "age":5}]}, {"name":"Hery", "age":54, "sponse":{"name":"Sane", "age":55}, "children":[{"name":"Jim", "age":12}, {"name":"John", "age":18}]}]
```