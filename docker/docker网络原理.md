以下内容引用[Docker —— 从入门到实践](http://dockerpool.com/static/books/docker_practice/advanced_network/README.html)
> 当 Docker 启动时，会自动在主机上创建一个 docker0 虚拟网桥，实际上是 Linux 的一个 bridge，可以理解为一个软件交换机。它会在挂载到它的网口之间进行转发。
同时，Docker 随机分配一个本地未占用的私有网段（在 RFC1918 中定义）中的一个地址给 docker0 接口。比如典型的 172.17.42.1，掩码为 255.255.0.0。此后启动的容器内的网口也会自动分配一个同一网段（172.17.0.0/16）的地址。
当创建一个 Docker 容器的时候，同时会创建了一对 veth pair 接口（当数据包发送到一个接口时，另外一个接口也可以收到相同的数据包）。这对接口一端在容器内，即 eth0；另一端在本地并被挂载到 docker0 网桥，名称以 veth 开头（例如 vethAQI2QT）。通过这种方式，主机可以跟容器通信，容器之间也可以相互通信。Docker 就创建了在主机和所有容器之间一个虚拟共享网络。如图
![docker network](static/img/network.png  "docker network")
>

下面以自定义的容器方式，一步步配置网络, 达到以下目标:

* 容器间能够通信
* 容器能够联外网

首先创建一个容器，但不使用默认网络配置，使用`--net=none`选项:
```bash
docker run -t -i --net=none ubuntu:14.04 bash
docker ps # 获取容器id=d344e6e05a99
```

获取容器pid:
```bash
docker inspect d344e6e05a99 | grep -i "\<pid\""
#  "Pid": 27383,
pid=27383
```
创建netns，并把容器放入新建的netns中，好像不能使用`ip netns`命令创建,使用以下方法创建:
```bash
sudo ln -s /proc/$pid/ns/net /var/run/netns/$pid
```
验证是否创建成功:
```bash
sudo ip netns show
# 27383
# ns1
# test
```
可见命名为27383的netns已经成功创建！

接下来创建一个veth对，其中一个设置为容器所在的netns
```bash
sudo ip link add name veth_d344 type veth peer name veth_d344_peer
sudo ip link set veth_d344_peer netns $pid
```
进入`$pid netns`设置网卡名称和ip:
```bash
sudo ip netns exec  27383 bash
sudo ip link set veth_d344_peer name eth0
sudo ifconfig  eth0 10.0.0.2/24 # 设置ip为10.0.0.2
ping 10.0.0.2 # 能ping通
exit
```
在容器中`ping 10.0.0.2`也能ping通,说明设置正确
```bash
ping 10.0.0.2 # 应该不通
docker exec d344e6e05a99 ping 10.0.0.2 # 成功ping通
```
创建网桥，并把veth另一端的虚拟网卡加入新创建的网桥中:
```bash
sudo brctl addbr br0 # 创建新网桥br0
sudo brctl addif br0 veth_d344 # 把虚拟网卡加入网桥br0中
sudo ifconfig br0 10.0.0.1/24 # 设置网桥ip
sudo ip link set veth_d344 up # 启动虚拟网卡
```
测试下:
```bash
ping 10.0.0.2 # 成功ping通
docker exec d344e6e05a99 ping 10.0.0.1 # 成功ping通
```
若以上两个都能ping通说明配置成功！

最后，我们需要使得容器能够联外网，需要设置NAT，使用iptables设置:
```bash
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o em1 -j MASQUERADE
```
设置容器默认路由为网桥ip（注意在容器内使用`route add` 添加, 会出现`SIOCADDRT: Operation not permitted`错误), 因此只能使用`ip netns exec`设置:
```bash
sudo ip netns exec 27383 route add default gw 10.0.0.1
```
测试，此时请确保宿主机能够联外网,进入容器内部:

```bash
ping baidu.com # 成功ping通，确保icmp没有被禁
```
