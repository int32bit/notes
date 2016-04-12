# 设置ssh连接会话复用

我们经常使用ssh连接远程主机，为了方便，避免每次登录输入密码，通常使用密钥登录。如果没有设置密钥，
则需要使用密码登录了，若每次都输入密码则十分繁琐。我们可以设置ssh连接会话复用，则登录成功后，会保持一段时间的会话，
在会话的生命周期内，再次登录同一台主机不需要输入密码。设置方法为：

## Step 1 创建会话保存目录

```bash
mkdir ~/.ssh/socks
```

## Step 2 配置ssh
修改`~/.ssh/config`文件，若该文件不存在，则创建。增加以下内容：

```
Host *
    KeepAlive yes
    ServerAliveInterval 60
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/socks/%h-%p-%r
```

设置完成后验证是否work：

```bash
ssh foo@bar
```
此时需要输入密码，退出重试，若成功则不需要输入密码。
