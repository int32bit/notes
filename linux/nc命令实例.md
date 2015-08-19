## nc命令实例

nc命令可用于发送任务tcp/udp连接和监听.

官方描述的主要功能包括:

* simple TCP proxies
* shell-script based HTTP clients and servers
* network daemon testing
* a SOCKS or HTTP ProxyCommand for ssh(1)
* and much, much more

下面看看官方的几个例子:

### 1. p2p简单聊天工具

在A机器运行(假设A机器主机名为`node1`:
```bash
nc -l 1234 # -l表示监听
```
在B机器运行:
```bash
nc node1 1234
```

此时从A或者B机器输入任何信息，都会在对方的机器中回显，实现了简单的即时聊天工具.

### 2. 文件传输

假设B机器有一个文件data.txt，需要传输到A机器:

在A机器:

```bash
nc -l 1234 >data.txt # data.txt需要保存的目标文件名
```

在B机器:
```bash
nc node1 1234 <data.txt # data.txt需要传输的文件
```

### 3.远程操作(类似ssh)

假设B需要远程操作A，又没有安装ssh:

在A机器:

```bash
rm -f /tmp/f; mkfifo /tmp/f
cat /tmp/f | /bin/sh -i 2>&1 | nc -l 127.0.0.1 1234 > /tmp/f
```

在B机器:

```
nc node1 1234
```

### 4.发送HTTP请求

```bash
echo "GET / HTTP/1.0\r\n\r\n" | nc localhost 80
```

### 5.端口扫描

```bash
# 查看主机名为node1的80端口是否开放
nc -zv node1 80
# 扫描主机名为node1的1～1024哪些端口是开放的
nc -zc node1 1-1024
```
