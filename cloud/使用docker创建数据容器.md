# 使用Docker创建数据容器
翻译自: [Data-only container madness](http://container42.com/2014/11/18/data-only-container-madness/)
## 1.什么是数据容器？

数据容器就是本身只创建一个`volume`供其他容器共享，创建完后即退出，不执行任何任务。比如通过以下方式创建一个`postgres`容器。

```sh
docker run --name dbdata postgres echo "Data-only container for postgres"
```
该容器运行`echo "Data-only container for postgres"`即退出，然而只要没有删除该容器，该容器`/var/lib/postgresql/data`的volume（在Dockerfile使用`VOLUME`指令定义)就会一直存在。

然后我们可以新建若干容器来共享数据，比如：
```sh
docker run -d --volumes-from dbdata --name db1 postgres
```
## 2.如何创建数据容器？

太简单了，创建任何容器，然后使用`-v`创建volume即可。但大家一定会想到用最小的镜像吧，比如`hello-world`,即

```sh
docker run -v /data hello-world
```
**但这样是错误的！** 为什么呢?

我们首先创建一个简单的镜像:

```Dockerfile
FROM debian:jessie
RUN useradd mickey
RUN mkdir /foo && touch /foo/bar && chown -R mickey:mickey /foo
USER mickey
CMD ls -lh /foo
```

构建:

```sh
docker build -t mickey_foo -< Dockerfile
```
运行下:

```sh
docker run --rm -v /foo mickey_foo
```
输出:

```
total 0
-rw-r--r-- 2 mickey mickey 0 Nov 18 05:58 bar
```
运行正常，没有任何问题。

下面我们尝试使用`busybox`来作为数据容器:

```sh
docker run -v /foo --name mickey_data busybox true
docker run --rm --volumes-from mickey_data mickey_foo
```
输出:

```
total 0
# Empty WTF??
```

```sh
docker run --rm --volumes-from mickey_data mickey_foo ls -lh /
```

```
total 68K
drwxr-xr-x   2 root root 4.0K Nov 18 06:02 bin
drwxr-xr-x   2 root root 4.0K Oct  9 18:27 boot
drwxr-xr-x   5 root root  360 Nov 18 06:05 dev
drwxr-xr-x   1 root root 4.0K Nov 18 06:05 etc
drwxr-xr-x   2 root root 4.0K Nov 18 06:02 foo
drwxr-xr-x   2 root root 4.0K Oct  9 18:27 home
drwxr-xr-x   9 root root 4.0K Nov 18 06:02 lib
drwxr-xr-x   2 root root 4.0K Nov 18 06:02 lib64
drwxr-xr-x   2 root root 4.0K Nov  5 21:40 media
drwxr-xr-x   2 root root 4.0K Oct  9 18:27 mnt
drwxr-xr-x   2 root root 4.0K Nov  5 21:40 opt
dr-xr-xr-x 120 root root    0 Nov 18 06:05 proc
drwx------   2 root root 4.0K Nov 18 06:02 root
drwxr-xr-x   3 root root 4.0K Nov 18 06:02 run
drwxr-xr-x   2 root root 4.0K Nov 18 06:02 sbin
drwxr-xr-x   2 root root 4.0K Nov  5 21:40 srv
dr-xr-xr-x  13 root root    0 Nov 18 06:05 sys
drwxrwxrwt   2 root root 4.0K Nov  5 21:46 tmp
drwxr-xr-x  10 root root 4.0K Nov 18 06:02 usr
drwxr-xr-x  11 root root 4.0K Nov 18 06:02 var
```
<div style='text-color:red;'> Owened by root?  WTF???</div>

```sh
docker run --rm --volumes-from mickey_data mickey_foo touch /foo/ba
```
```
touch: cannot touch '/foo/bar': Permission denied
```
发生了什么呢？我们的`/foo` 仍然存在, 但是它是空的并且所有者是`root`？

让我们再试试使用我们刚刚构建的`mickey_foo`作为数据容器:
```
~: docker rm -v mickey_data # remove the old one
mickey_data
~: docker run --name mickey_data -v /foo mickey_foo true
~: docker run --rm --volumes-from mickey_data mickey_foo
total 0
-rw-r--r-- 1 mickey mickey 0 Nov 18 05:58 bar
# Yes!
~: docker run --rm --volumes-from mickey_data mickey_foo ls -lh /
total 68K
drwxr-xr-x   2 root   root   4.0K Nov 18 06:02 bin
drwxr-xr-x   2 root   root   4.0K Oct  9 18:27 boot
drwxr-xr-x   5 root   root    360 Nov 18 06:11 dev
drwxr-xr-x   1 root   root   4.0K Nov 18 06:11 etc
drwxr-xr-x   2 mickey mickey 4.0K Nov 18 06:10 foo
drwxr-xr-x   2 root   root   4.0K Oct  9 18:27 home
drwxr-xr-x   9 root   root   4.0K Nov 18 06:02 lib
drwxr-xr-x   2 root   root   4.0K Nov 18 06:02 lib64
drwxr-xr-x   2 root   root   4.0K Nov  5 21:40 media
drwxr-xr-x   2 root   root   4.0K Oct  9 18:27 mnt
drwxr-xr-x   2 root   root   4.0K Nov  5 21:40 opt
dr-xr-xr-x 121 root   root      0 Nov 18 06:11 proc
drwx------   2 root   root   4.0K Nov 18 06:02 root
drwxr-xr-x   3 root   root   4.0K Nov 18 06:02 run
drwxr-xr-x   2 root   root   4.0K Nov 18 06:02 sbin
drwxr-xr-x   2 root   root   4.0K Nov  5 21:40 srv
dr-xr-xr-x  13 root   root      0 Nov 18 06:05 sys
drwxrwxrwt   2 root   root   4.0K Nov  5 21:46 tmp
drwxr-xr-x  10 root   root   4.0K Nov 18 06:02 usr
drwxr-xr-x  11 root   root   4.0K Nov 18 06:02 var
# YES!!
~: docker run --rm --volumes-from mickey_data mickey_foo touch /foo/baz
~: docker run --rm --volumes-from mickey_data mickey_foo ls -lh /foo
total 0
-rw-r--r-- 1 mickey mickey 0 Nov 18 06:11 bar
-rw-r--r-- 1 mickey mickey 0 Nov 18 06:12 baz
# YES!!!
```
由于我们刚刚使用了相同的镜像作为数据容器镜像，共享的容器能够找到共享数据。为什么使用`busybox`不可以呢？由于`busybox`没有`/foo`这个目录，当我们使用`-v`创建`/foo`这个数据卷时，docker会以默认用户自动创建对应的目录（这里是root)，而`--volumes-from`仅仅是重用存在的卷，而不会对卷自动做任何事情。因此当我们尝试去写`/foo`时由于没有权限(root所有，mickey用户).

**因此我们应该使用和共享的容器相同的镜像做数据容器镜像？是的!**

那我们使用这么大的镜像不会浪费空间么?

## 3. 为什么不使用小镜像作为数据容器？

其中一个原因，在上一节已经解释。遗留的一个问题是使用这么大的镜像(因为一般的镜像都会比较大)会不会浪费空间呢？

首先我们需要知道Docker的文件系统是如何工作的。Docker镜像是由多个文件系统（只读层）叠加而成。当我们启动一个容器的时候，Docker会加载只读镜像层并在其上（译者注：镜像栈顶部）添加一个读写层。如果运行中的容器修改了现有的一个已经存在的文件，那该文件将会从读写层下面的只读层复制到读写层，该文件的只读版本仍然存在，只是已经被读写层中该文件的副本所隐藏。当删除Docker容器，并通过该镜像重新启动时，之前的更改将会丢失。在Docker中，只读层及在顶部的读写层的组合被称为Union File System（联合文件系统）。

因此当我们创建了一个debian容器实例时（大约150MB），根据以上的原理，我们再创建1000个debian镜像能够重用原来的只读层，需要的空间还是150MB.

容器本身并不会占任何空间，除非你修改了内容。

**因此Docker无论创建一个镜像的多少实例，都不会占据更多的空间。**

因此实际上，我们为了创建数据容器而使用`busybox`反而会占用更多的空间，这个空间就是`busybox`的镜像大小。

实际上我们经常这样使用:

```
~: docker run --name mydb-data --entrypoint /bin/echo mysql Data-only container for mydb
~: docker run -d --name mydb --volumes-from mydb-data mysql
```

上面的实例指行`/bin/echo mysql Data-only container for mydb`,能够更容易知道这是一个数据容器，利于使用`grep`查找.


