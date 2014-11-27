# bash字符串前美元符号的作用

## problem

bash内置变量IFS作为内部单词分隔符，其默认值为\<space\>\<tab\>\<newline\>, 我想设置它仅为\n,于是：
```bash
OLD_IFS=$IFS
IFS='\n'
# do some work here
IFS=$OLD_IFS
```
但结果为：IFS把单独的字符当作了分隔符，即分隔符被设置成下划线和字母n 。

**Why ?**

## Solution

通过google搜索，得知需要把\n转化成[ANSI-C Quoting](http://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html),
方法是把字符串放入$'string'中，即应该设置成:
```bash
IFS=$'\n'
```
顺便搜了下$字符的用途，在[Unix & Linux](http://unix.stackexchange.com/questions/48106/what-does-it-mean-to-have-a-dollarsign-prefixed-string-in-a-script),
中解释了字符串前面加$字符的两种形式，一种是单引号，一种是双引号，即
> There are two different things going on here, both documented in the bash manual
### $'
Dollar-sign single quote is a special form of quoting:
ANSI C Quoting
    Words of the form $'string' are treated specially. The word expands to string, with backslash-escaped characters replaced as specified by the ANSI C standard.
### $"
Dollar-sign double-quote is for localization:
Locale translation
    A double-quoted string preceded by a dollar sign (‘$’) will cause the string to be translated according to the current locale. If the current locale is C or POSIX, the dollar sign is ignored.
    If the string is translated and replaced, the replacement is double-quoted.
    
  因此单引号表示转化成ANSI-C字符，双引号则表示将字符串本地化。
  
  以下是一个实例，ping /etc/hosts的主机名为video-开头的主机名，检查网络状况!
  
  ```bash
  #!/bin/bash
trap "echo 'interrupted!';exit 1" SIGHUP SIGINT SIGTERM
OLD_IFS=$IFS
IFS=$'\n'
for i in `awk '$0!~/^$/ && $0!~/^#/ && $2~/^video/ {print $1,$2}' /etc/hosts`
do
	ADDR=$(echo $i | cut -d' ' -f 1)
	DOMAIN=$(echo $i | cut -d' ' -f 2)
	if ping -c 2 $ADDR &>/dev/null
	then
		echo $DOMAIN ok!
	else
		echo $DOMIN dead!
	fi
done
IFS=$OLD_IFS
```
