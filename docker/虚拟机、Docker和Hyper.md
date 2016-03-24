## 操作系统

 我们知道:
<div style='color:red;font-size:20px;'>
完整的操作系统=内核+apps
</div>
内核负责管理底层硬件资源，包括CPU、内存、磁盘等等，并向上为apps提供系统调用接口，上层apps应用必须通过系统调用方式使用硬件资源，通常并不能直接访问资源。apps就是用户直接接触的应用，比如命令行工具、图形界面工具等（linux的图形界面也是作为可选应用之一，而不像windows是集成到内核中的）。同一个内核加上不同的apps，就构成了不同的操作系统发行版，比如ubuntu、rethat、android（当然内核通常针对不同的发行版会有修改）等等。因此我们可以认为，不同的操作系统发行版本其实就是由应用apps构成的环境的差别（比如默认安装的软件以及链接库、软件包管理、图形界面应用等等）。我们把所有这些apps环境打成一个包，就可以称之为镜像。问题来了，假如我们同时有多个apps环境，能否在同一个内核上运行呢？因为操作系统只负责提供服务，而并不管为谁服务，因此同一个内核之上可以同时运行多个apps环境。比如假设我们现在有ubuntu和fedora的apps环境，即两个发行版镜像，分别位于`/home/int32bit/ubuntu`和`/home/int32bit/fedora`，我们最简单的方式，采用`chroot`工具即可快速切换到指定的应用环境中，相当于同时有多个apps环境在运行。

## 容器技术

我们以上通过chroot方式，好像就已经实现了容器的功能，但其实容器并没有那么简单，工作其实还差得远。首先要作为云资源管理还必须满足：

### 1.资源隔离
因为云计算本质就是集中资源再分配（社会主义），再分配过程就是资源的逻辑划分，提供资源抽象的实现方式比如我们熟悉的虚拟机等，我们把资源抽象一次划分称为单元。单元必须满足隔离性，包括用户隔离（或者说权限隔离）进程隔离、网络隔离、文件系统隔离等，即单元内部只能感知其内部的资源，而不能感知单元以外的资源（包括宿主资源以及其他单元的资源）。
### 2.资源控制
即为单元分配资源量，能控制单元的资源最大使用量。单元不能使用超过分配的资源量。

当然还包括其他很多条件，本文主要基于这两个基本条件进行研究。

显然满足以上两个条件，虚拟机是一种实现方式，这是因为：

* 隔离毋容置疑，因为不同的虚拟机运行在不同的内核，虚拟机内部是一个独立的隔离环境
* hypervisor能够对虚拟机分配指定的资源

基于虚拟机快速构建应用环境比如`vagrant`等。

但是虚拟机也带来很多问题，比如：

* 镜像臃肿庞大，不仅包括apps，还必须包括一个庞大的内核
* 创建和启动时间开销大，不利于快速构建重组
* 额外资源开销大，部署密度小
* 性能损耗
* ...

有没有其他实现方式能符合以上两个条件呢？容器技术便是另一种实现方式。表面上和我们使用chroot方式相似，即所有的容器实例内部的应用是直接运行在宿主机中，所有实例共享宿主机的内核，而虚拟机实例内部的进程是运行在GuestOS中。由以上原理可知，容器相对于虚拟机有以上好处：

* 镜像体积更小，只包括应用以及所依赖的环境，没有内核。
* 创建和启动快，不需要启动GuestOS，应用启动开销基本就是应用本身启动的时间开销。
* 无GuestOS，无hypervisor，无额外资源开销，资源控制粒度更小，部署密度大。
* 使用的是真实物理资源，因此不存在性能损耗。
* ...

但如何实现资源隔离和控制呢？

### 1. 隔离性

主要通过内核提供namespace技术实现隔离性，以下参考[酷壳](http://coolshell.cn/articles/17010.html):
>Linux Namespace是Linux提供的一种内核级别环境隔离的方法。不知道你是否还记得很早以前的Unix有一个叫chroot的系统调用（通过修改根目录把用户jail到一个特定目录下），chroot提供了一种简单的隔离模式：chroot内部的文件系统无法访问外部的内容。Linux Namespace在此基础上，提供了对UTS、IPC、mount、PID、network、User等的隔离机制。
>

Linux Namespace 有如下种类，官方文档在这里[《Namespace in Operation》](http://lwn.net/Articles/531114/)

| 分类 |	系统调用参数 | 相关内核版本
|---------|------------------------|----------------------|
|Mount namespaces|	CLONE_NEWNS | Linux 2.4.19
|UTS namespaces | CLONE_NEWUTS|Linux 2.6.19
|IPC namespaces	|CLONE_NEWIPC|Linux 2.6.19
|PID namespaces	|CLONE_NEWPID|	Linux 2.6.24
|Network namespaces|CLONE_NEWNET|始于Linux 2.6.24 完成于 Linux 2.6.29
|User namespaces|CLONE_NEWUSER|始于 Linux 2.6.23 完成于 Linux 3.8)

由上表可知，通过Namespaces技术可以实现隔离性，比如网络隔离，我们可以通过`sudo ip netns ls`查看网络命名空间，通过`ip netns add NAME`增加网络命名等。

### 2.资源控制
内核实现了对进程组的资源控制，即Linux Control Group，简称cgoup，它能为系统中运行进程组根据用户自定义组分配资源。简单来说，可以实现把多个进程合成一个组，然后对这个组的资源进行控制，比如CPU使用时间，内存大小、网络带宽、磁盘读写等，linux把cgroup抽象成一个虚拟文件系统，可以挂载到指定的目录下，ubuntu14.04默认自动挂载在`/sys/fs/cgroup`下，用户也可以手动挂载，比如挂载memory子系统（子系统一类资源的控制，比如cpu、memory，blkio等）到`/mnt`下：

```bash
sudo mount  -t cgroup -o memory  memory /mnt
```
挂载后就能像查看文件一样方便浏览进程组以及资源控制情况，控制组并不是孤立的，而是组织成树状结构构成进程组树，控制组的子节点会继承父节点。下面以memory子系统为例，

```bash
ls /sys/fs/cgroup/memory/
```
输出：

```
cgroup.clone_children  memory.kmem.failcnt                 memory.kmem.tcp.usage_in_bytes   memory.memsw.usage_in_bytes      memory.swappiness
cgroup.event_control   memory.kmem.limit_in_bytes          memory.kmem.usage_in_bytes       memory.move_charge_at_immigrate  memory.usage_in_bytes
cgroup.procs           memory.kmem.max_usage_in_bytes      memory.limit_in_bytes            memory.numa_stat                 memory.use_hierarchy
cgroup.sane_behavior   memory.kmem.slabinfo                memory.max_usage_in_bytes        memory.oom_control               notify_on_release
docker                 memory.kmem.tcp.failcnt             memory.memsw.failcnt             memory.pressure_level            release_agent
memory.failcnt         memory.kmem.tcp.limit_in_bytes      memory.memsw.limit_in_bytes      memory.soft_limit_in_bytes       tasks
memory.force_empty     memory.kmem.tcp.max_usage_in_bytes  memory.memsw.max_usage_in_bytes  memory.stat                      user
```

以上是根控制组的资源限制情况，我们以创建控制内存为4MB的Docker容器为例：

```bash
docker run  -m 4MB -d busybox ping localhost
```

返回id为`0532d4f4af67`，自动会创建以docker实例id为为名的控制组，位于`/sys/fs/cgroup/memory/docker/0532d4f4af67...`，我们查看该目录下的`memory.limit_in_bytes`文件内容为：

```bash
cat memory.limit_in_bytes
4194304
```
即最大的可使用的内存为4MB，正好是我们启动Docker所设定的。

由以上可知，容器实现了资源的隔离性以及控制性。

## Docker技术

