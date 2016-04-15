# 配置kafka集群
虽然很简单，但会遇到很多奇怪的坑，而且网上解决方法搜不到。
首先下载kafka包，解压缩后，修改`conf/server.properties`文件,基本配置项如下（省略了部分默认配置项 :
```
broker.id=0
advertised.host.name=master
zookeeper.connect=master:2181,node1:2181,node2:2181
```
以上需要注意的是`advertised.host.name`必须修改为主机名，否则会导致很多问题。
每个主机的`broker.id`必须不一样。`zookeeper.connect`需要填写所有的zookeeper服务器地址端口，并且以上的主机名对应的node1，node2,...必须和`/etc/hosts`一致，并且集群外可以ping通(集群内可以使用内部ip，集群外使用外部ip，但主机名对应的机器必须一一对应，否则会出现`Leader not local for partition`错误，这是其中一个坑，搞了很久没有搞清楚.

配置修改后，创建一个topic(topic一旦创建不能删除？只能标记为已删除?):
```sh
bin/kafka-topics.sh --create --partitions 5 --replication-factor 3 --topic test3 --zookeeper master,node1,node2
```
获取主题信息
```sh
bin/kafka/bin$ ./kafka-topics.sh --describe --topic test3 --zookeeper master,node1
```
输出:
```
Topic:test3     PartitionCount:5        ReplicationFactor:3     Configs:
        Topic: test3    Partition: 0    Leader: 4       Replicas: 4,2,3 Isr: 4,2,3
        Topic: test3    Partition: 1    Leader: 5       Replicas: 5,3,4 Isr: 5,3,4
        Topic: test3    Partition: 2    Leader: 6       Replicas: 6,4,5 Isr: 6,4,5
        Topic: test3    Partition: 3    Leader: 7       Replicas: 7,5,6 Isr: 7,5,6
        Topic: test3    Partition: 4    Leader: 0       Replicas: 0,6,7 Isr: 0,6,7
```
以上的Replicas和lsr必须一样，否则说明对应的broker down掉了。