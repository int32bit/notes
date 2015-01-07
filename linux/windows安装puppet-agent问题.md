# 中文版本windows系统安装puppet agent问题

## 1. How to install

windows pupppet只能安装agent，安装过程，在[这里](https://docs.puppetlabs.com/pe/latest/install_windows.html).
安装过程比较简单，但在运行agent时会遇到几个问题。

## 2. Error: Could not run: ”\xB2" to UTF-8 in conversion from ASCII-8BIT to UTF-8 to UTF-16LE

这是win32-dir库bug，需要升级，使用管理员身份运行*start command prompt with puppet*，然后运行：
```sh
gem install win32-dir
gem list
```
确保运行gem list后win32-dir版本大于0.4.3。

## 3. could not intern from pson XXXX

这是由于编码问题造成的，master在获取facter变量时不能有中文（或者保证传输的编码和master一致），运行facter后发现*timezone*
输出中文。简单的解决办法是，修改facter的timezone，位于
```
安装路径:C:\Program Files\Puppet Labs\Puppet\facter\lib\facter.
```
根据实际情况修改setcode值，我是直接硬编码为"UTC+8",或者可以参照世界时区标准记法。

##  certificate verify failed: [CRL is not yet valid for /CN controller

这是由于agent和master clock不同步造成的，openstack中创建windows云主机时需要指os_type为windows，才能社会之RTC为localtime，否则时间会不准。
