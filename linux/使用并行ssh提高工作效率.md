我们经常需要`ssh`到多个主机上执行相同的命令，为了提高效率，我们通常会自己写个脚本，循环遍历执行我们的命令，比如：

```bash
for host in `cat hosts.txt`;do
    ssh username@$host cmd
done
```
采用这种方式的问题是：

* 必须自己写脚本，且正确性没法保证。
* 各个主机执行任务是串行的，必须前一台主机执行完毕后，下一台主机才能执行，难以实现并行执行。

我们可以使用`parallel-ssh`工具来实现并行`ssh`远程执行命令,它是一个python编写可以在多台服务器上执行命令的工具，同时支持拷贝文件，目标也是简化大量计算机的管理，项目地址：https://code.google.com/p/parallel-ssh/
`pssh` 包安装5个实用程序：`parallel-ssh`、`parallel-scp`、`parallel-slurp`、`parallel-nuke`和`parallel-rsync`。每个实用程序都并行地操作多个主机。

* parallel-ssh 在多个主机上并行地运行命令。
* parallel-scp 把文件并行地复制到多个主机上。
* parallel-rsync 通过 rsync 协议把文件高效地并行复制到多个主机上。
* parallel-slurp 把文件并行地从多个远程主机复制到中心主机上。
* parallel-nuke 并行地在多个远程主机上杀死进程。

使用它首先需要安装，ubuntu已经集成到软件包中，直接使用`apt-get`安装：

```bash
sudo apt-get install pssh
```

为了简便，设置以下alias：

```bash
alias pssh='parallel-ssh'
alias pscp='parallel-scp'
```

编写需要远程操作的host列表`hosts.txt`:

```
node1
node2
node3
...
node100
```

使用时需要指定用户名和输入用户密码（必须所有主机的用户和密码相同）以及远程主机列表，通过`-l username`选项指定用户名，使用`-A`选项指定需要输入密码，使用`-h`指定主机列表，比如在所有的主机执行`uptime`操作：

```bash
pssh -P -l foo -A -h hosts.txt uptime
```

若我们当前主机的登录名为`fgp`，且`fgp`能够免密码登录`hosts.txt`的所有主机，则可以省略用户名和密码。比如，所有的主机执行`uptime`操作，并打印结果：

```bash
pssh -P -h  hosts.txt uptime
```

主机太多了，把输出保存到文件中：

```bash
pssh -o uptime_result -h  hosts.txt uptime
```

传输本地文件到所有的主机中：

```bash
pscp -h hosts.txt local_file.txt ~/target_file.txt
```

以上是简单使用方法，掌握以上的这些操作足够完成我们大多数工作，提高工作效率。

LikeBe the first to like this
No labels Edit Labels
User icon: Add a picture of yourself
Write a comment…
