## 安装docker

测试环境: `ubuntu14.04` 64位

### 一命令式安装

```bash
wget -qO- https://get.docker.com/ | sh
```

### 把用户加入docker组

默认只有root用户能进行操作，不过docker组也具有权限，因此若需要当前用户不需要root
也能访问docker，需要把用户加入到docker组:

```bash
sudo usermod -a -G docker username
```

### 启动docker服务

```bash
sudo service docker start
```

### 测试是否安装好

```bash
docker info
```
若输出以下则说明安装成功
```
Containers: 0
Images: 0
Storage Driver: aufs
Root Dir: /var/lib/docker/aufs
Backing Filesystem: extfs
Dirs: 0
Dirperm1 Supported: true
Execution Driver: native-0.2
Logging Driver: json-file
Kernel Version: 3.16.0-41-generic
Operating System: Ubuntu 14.04.2 LTS
CPUs: 4
Total Memory: 7.707 GiB
Name: Alibaba-fgp
ID: GA2K:3OV2:GNVU:PETS:DBZR:OYYP:FHWE:3QM5:QZPW:XNCM:IHP6:U2KN
```

### 启动第一个实例

```bash
docker run -t -i --rm busybox
```

此时应该会先从docker hub中拉取镜像，然后启动容器实例

### 其他命令

```bash
docker images #查看本地镜像
docker search hadoop #搜索hadoop相关镜像
docker pull krystism/openstackclient # 下载krystism/openstackclient镜像到本地
docker ps # 查看运行实例
docker ps -a # 查看所有实例，包括没有运行的
docker run -t -i ubuntu:14.04 # 运行ubuntu 14.04镜像
docker start id # 启动指定id实例（开机)
docker stop id # 停止指定id实例(关机)
docker rm id # 删除指定id实例(移除)
docker rmi id # 删除指定i镜像
```
