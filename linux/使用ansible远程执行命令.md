# 使用ansible远程执行命令
## 1.ansible简介
ansible的官方定义：“Ansible is Simple IT Automation”——简单的自动化IT工具。这个工具的目标：

* 自动化部署APP
* 自动化管理配置项
* 自动化的持续交付
* 自动化的（AWS）云服务管理。

其本质上就是在远程在多台服务器执行一系列命令和文件同步，和以前的介绍的[使用并行ssh提高工作效率](https://github.com/int32bit/notes/blob/master/linux/使用并行ssh提高工作效率.md)功能类似，他们都是使用ssh协议进行远程操作，但ansible比pssh功能更强大，比如支持主机列表分组、支持playbook模板文件等。本文仅仅介绍ansible的Ad-Hoc用法，即默认的command模块，直接在shell执行命令。

## 2.安装

ubuntu14.04直接使用`apt-get`安装：

```bash
sudo apt-get install -y ansible
```
也可以使用pip命令安装：

```bash
sudo pip install ansible
```

为了支持输入远程主机用户密码，还需要安装`sshpass`工具：

```bash
sudo apt-get install -y sshpass
```
安装完成后创建~/.hosts文件，内容如下:

```
[local]
ceph-0
[mon]
ceph-1
[osd]
ceph-2
ceph-3
```
以上配置文件定义了三个主机组，分别为`local`、`mon`、`osd`，`ceph-x`是主机名。ansible执行需要指定主机列表文件，默认为`/etc/hosts`,用户也可以通过`-i hosts_file`指定，我们修改默认文件为我们刚刚创建的新文件，创建`~/.ansible.cfg`,增加以下内容:

```cfg
[defaults]
hostfile=~/.hosts
```

## 3.使用ansible
ansible的简单语法为：

```bash
ansible <host-pattern> [-f forks] [-m module_name] [-a args]
```
其中`host-pattern`指定主机组，比如上面的`osd`、`local`等，`-f`指定并行数，默认为`5`，`-m`指定模块名，比如`ping`表示探测远程主机是否可访问，`command`表示执行`shell`命令，`copy`表示传输文件等，默认为`command`，`-a`是指定选项参数，不同的模块具有不同的参数，比如`ping`不需要选项，`command`需要指定执行的命令，`copy`需要指定`src`和`dest`等。另外还有以上提到的`-i`指定主机列表文件、`-u`指定远程执行用户名等。
在所有的osd节点执行`uptime`操作,远程主机必须有一样的用户名和密码，如果不指定用户名，则默认使用当前登录主机的用户名，否则如果和登录主机用户名不一样，必须通过`-u username`指定远程主机：

```bash
ansible osd -a 'uptime'
```
输出：

```
ceph-3 | FAILED => SSH encountered an unknown error during the connection. We recommend you re-run the command using -vvvv, which will enable SSH debugging output to help diagnose the issue
ceph-2 | FAILED => SSH encountered an unknown error during the connection. We recommend you re-run the command using -vvvv, which will enable SSH debugging output to help diagnose the issue
```
命令执行失败，我们使用`-vvvv`选项查看详细信息：

```bash
ansible -vvvv osd -a 'uptime'
```
输出：

```
ebug1: Trying private key: /home/fgp/.ssh/id_rsa
debug3: no such identity: /home/fgp/.ssh/id_rsa: No such file or directory
debug1: Trying private key: /home/fgp/.ssh/id_dsa
debug3: no such identity: /home/fgp/.ssh/id_dsa: No such file or directory
debug1: Trying private key: /home/fgp/.ssh/id_ecdsa
debug3: no such identity: /home/fgp/.ssh/id_ecdsa: No such file or directory
debug1: Trying private key: /home/fgp/.ssh/id_ed25519
debug3: no such identity: /home/fgp/.ssh/id_ed25519: No such file or directory
debug2: we did not send a packet, disable method
debug1: No more authentication methods to try.
Permission denied (publickey,password).
```
说明我们既没有密钥文件也没有输入用户密码，因此无法通过ssh认证，需要输入密码，使用`-k`选项：

```
➜  ~ ansible  osd -a 'uptime' -k
SSH password:
ceph-2 | success | rc=0 >>
 11:01:17 up 1 day, 6 min,  5 users,  load average: 0.02, 0.02, 0.05

ceph-3 | success | rc=0 >>
 11:01:17 up 1 day, 6 min,  5 users,  load average: 0.03, 0.03, 0.05
```
执行成功了，输入一次密码后，ansible会保存认证session，在session有效期内，不需要重复输入密码，即在执行了以上命令后，不需要再传递`-k`参数：

```
➜  ~ ansible  osd -a 'uptime'
ceph-2 | success | rc=0 >>
 11:02:14 up 1 day, 7 min,  5 users,  load average: 0.01, 0.02, 0.05

ceph-3 | success | rc=0 >>
 11:02:14 up 1 day, 7 min,  5 users,  load average: 0.01, 0.02, 0.05
```
有效期只有几分钟时间，为了避免每次输入密码，建议还是通过设置密钥来实现免密码登录，若本地还没有生成密钥文件，则先使用`ssh-keygen`命令生成密钥文件：

```
➜  ~ ssh-keygen                                                                                                                                                              [1/1877]
Generating public/private rsa key pair.
Enter file in which to save the key (/home/fgp/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/fgp/.ssh/id_rsa.
Your public key has been saved in /home/fgp/.ssh/id_rsa.pub.
The key fingerprint is:
49:8b:d0:a0:29:69:c8:32:50:3d:fc:8a:0a:4e:c8:1d fgp@ceph-0
The key's randomart image is:
+--[ RSA 2048]----+
|...o.            |
|+. o+o           |
|*oo .o. .        |
|oo E ..o o       |
|o ..... S        |
|oo...            |
|+.               |
|..               |
|                 |
+-----------------+
```
我们把`~/.ssh/id_rsa.pub`文件拷贝到所有的主机，拷贝文件需要指定`-m`模块名为`copy`，指定所有的主机的`host-pattern`为`all`:

```bash
ansible all -m copy -a 'src=~/.ssh/id_rsa.pub dest=~' -k
ansible all -a 'ls' -k # 查看是否传输成功
```
接下来把公钥追加到`~/.ssh/authorized_keys`中,我们需要执行`cat ~/id_rsa.pub >> ~/.ssh/`命令，但默认的`command`模块是不支持重定向和管道的，为了使用重定向和管道，我们使用`shell`模块：

```bash
ansible all -m shell -a 'mkdir -p .ssh' # assure ~/.ssh exist!
ansible all -m shell -a 'cat ~/id_rsa.pub >>  ~/.ssh/authorized_keys' -k
```
验证下是否工作，注意下面的命令没有指定`-k`选项：

```bash
ansible all -m shell -a 'cat .ssh/authorized_keys'
```
输出：

```
➜  ~ ansible all -m shell -a 'cat .ssh/authorized_keys'                                                                                                                      [1/1839]
ceph-0 | success | rc=0 >>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxjl++nrmghoRVQnnJALR8Ia6eD87hdewZ9XZP9Ay3ZU1eU9F5MF0A7I7UY08kY7az7+14YJeP0T+zhEl8trc6NDV47LJnMG8ONVePokCeCvFgukUa8QpAhMWXSRSyUFA3Q4LpVmRu2nat$lSrwhu0W7uazq9OA5YxSCZRV/lb6bTsrrywBT4s9Crr5DWKUeZ1uKeUVghz0KmxH/ICWyFGE3v3OsqTMvtWM/R5m6FIgb86bd3CsM4UAP4v5I4FEx4+iqsbtvww3qOkY3Qj91AGOuYq8yNhFmQVN7VZZ9OR/8Vc0iI1wOG+vylbEJjr0/pjX$pPzPrOtW0Q6PjTKZXL fgp@ceph-0

ceph-3 | success | rc=0 >>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxjl++nrmghoRVQnnJALR8Ia6eD87hdewZ9XZP9Ay3ZU1eU9F5MF0A7I7UY08kY7az7+14YJeP0T+zhEl8trc6NDV47LJnMG8ONVePokCeCvFgukUa8QpAhMWXSRSyUFA3Q4LpVmRu2nat$lSrwhu0W7uazq9OA5YxSCZRV/lb6bTsrrywBT4s9Crr5DWKUeZ1uKeUVghz0KmxH/ICWyFGE3v3OsqTMvtWM/R5m6FIgb86bd3CsM4UAP4v5I4FEx4+iqsbtvww3qOkY3Qj91AGOuYq8yNhFmQVN7VZZ9OR/8Vc0iI1wOG+vylbEJjr0/pjX$pPzPrOtW0Q6PjTKZXL fgp@ceph-0

ceph-2 | success | rc=0 >>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxjl++nrmghoRVQnnJALR8Ia6eD87hdewZ9XZP9Ay3ZU1eU9F5MF0A7I7UY08kY7az7+14YJeP0T+zhEl8trc6NDV47LJnMG8ONVePokCeCvFgukUa8QpAhMWXSRSyUFA3Q4LpVmRu2nat$lSrwhu0W7uazq9OA5YxSCZRV/lb6bTsrrywBT4s9Crr5DWKUeZ1uKeUVghz0KmxH/ICWyFGE3v3OsqTMvtWM/R5m6FIgb86bd3CsM4UAP4v5I4FEx4+iqsbtvww3qOkY3Qj91AGOuYq8yNhFmQVN7VZZ9OR/8Vc0iI1wOG+vylbEJjr0/pjX$pPzPrOtW0Q6PjTKZXL fgp@ceph-0

ceph-1 | success | rc=0 >>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxjl++nrmghoRVQnnJALR8Ia6eD87hdewZ9XZP9Ay3ZU1eU9F5MF0A7I7UY08kY7az7+14YJeP0T+zhEl8trc6NDV47LJnMG8ONVePokCeCvFgukUa8QpAhMWXSRSyUFA3Q4LpVmRu2nat$lSrwhu0W7uazq9OA5YxSCZRV/lb6bTsrrywBT4s9Crr5DWKUeZ1uKeUVghz0KmxH/ICWyFGE3v3OsqTMvtWM/R5m6FIgb86bd3CsM4UAP4v5I4FEx4+iqsbtvww3qOkY3Qj91AGOuYq8yNhFmQVN7VZZ9OR/8Vc0iI1wOG+vylbEJjr0/pjX$pPzPrOtW0Q6PjTKZXL fgp@ceph-0
```
可见我们免密码执行远程命令，并且验证了公钥已经追加到`~/.ssh/authorized_keys`中。
下面我们执行一下更新操作，命令为`apt-get update -y`:

```bash
ansible all -m shell -a 'apt-get update -y'
```
输出结果：

```
ceph-1 | FAILED | rc=100 >>
E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
E: Unable to lock directory /var/lib/apt/lists/
E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)
E: Unable to lock the administration directory (/var/lib/dpkg/), are you root?

ceph-2 | FAILED | rc=100 >>
E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
E: Unable to lock directory /var/lib/apt/lists/
E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)
E: Unable to lock the administration directory (/var/lib/dpkg/), are you root?

ceph-3 | FAILED | rc=100 >>
E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
E: Unable to lock directory /var/lib/apt/lists/
E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)
E: Unable to lock the administration directory (/var/lib/dpkg/), are you root?
```
执行失败了，显然是由于没有root权限，需要使用sudo执行命令，需要`--sudo``选项：

```bash
ansible all --sudo -m shell -a 'apt-get update -y'
```
如果没有密钥，需要输入sudo密码，需要指定`-K`选项（大写的K）。

## 4.总结
ansible的功能非常强大，以上只介绍了如何在命令行远程执行命令，ansible还有更强大的playbook功能，playbook通过yaml文件定义，类似puppet的模板文件，具体可以参考官方文档。
