# 制作windows puppet镜像过程

由于电信需要远程部署软件，拟使用puppet进行远程服务管理
## 前提
1. windows系统已经安装
2. windows已经安virtio driver
3. 远程桌面开启，最好关闭防火墙

## 设置MTU

在没有安装cloudinit情况下需要手动配置mtu大小为1454，否则无法

## 设置hosts文件

把一些常用的host放到C:/windows/system32/driver/etc/host，**尤其是master的，务必设置！！**

## 设置时间同步

agent需要和master保持时间同步，因此需要设置windows更新时间服务器为master

## 安装win32-dir

需要安装win32-dir 版本大于0.43, 安装方法为管理员start command prompt with puppet, run:
```sh
gem install win32-dir
```

## 修改puppet facter下的timezone

timezone默认输出中文，会出现编码错误,设置setcode 为英文字符，最好是世界时区标准格式

## 安装clouinit
下载地址:[官网](http://www.cloudbase.it/cloud-init-for-windows-instances/)
## 关机
在这前清空puppet ssl目录，位于C：/programdata，并根据实际情况可以设置puppet.conf 。为了减少磁盘文件大小，最好运行下磁盘
清理，并删除掉一些无用文件。

##  格式转化

把格式转化，一方面为了合并base image，另一方面也可以起到重新整理磁盘文件，减少文件大小，run：

```sh
qemu-img convert -O qcow2 origin.qcow2 new.qcow2
```
