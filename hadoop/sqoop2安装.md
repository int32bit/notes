# sqoop2安装

## 1. 下载解压缩

此次安装版本为1.99.6

```sh
# Decompress Sqoop distribution tarball
tar -xvf sqoop-<version>-bin-hadoop<hadoop-version>.tar.gz


ln -s sqoop-<version>-bin-hadoop<hadoop version>.tar.gz sqoop

export SQOOP_HOME=`pwd`/sqoop
# Change working directory
cd $SQOOP_HOME
```

## 2. 配置服务

配置文件在`$SQOOP_HOME/server/conf`下，大多数默认配置即可。需要注意的配置是`catalina.properties`文件,`common_loader`配置
hadoop库文件，包括hdfs、mapreduce、hive等所有jar包. 我的配置为:
```
common.loader=${catalina.base}/lib,${catalina.base}/lib/*.jar,${catalina.home}/lib,${catalina.home}/lib/*.jar,${catalina.home}/../lib/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop/lib/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop-hdfs/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop-hdfs/lib/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/lib/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop-yarn/*.jar,/opt/cloudera/parcels/CDH/lib/hadoop-yarn/lib/*.jar,/opt/cloudera/parcels/CDH/lib/hive/lib/*.jar
```

`sqoop.properties`文件的`org.apache.sqoop.submission.engine.mapreduce.configuration.directory=/etc/hadoop/conf/`配置hadoop
配置文件路径，默认为`/etc/hadoop/conf`

## 3. 测试配置是否正确

运行
```
sqoop2-tool verify
```
若正确,则输出为:

```
Verification was successful.
Tool class org.apache.sqoop.tools.tool.VerifyTool has finished correctly
```

## 4. 下载derby 包
org.apache.sqoop.common.SqoopException: JDBCREPO_0007:Unable to lease link
