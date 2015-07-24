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

配置文件在`$SQOOP_HOME/server/conf`下，大多数默认配置即可。需要注意的配置是`catalina.properties`文件下`common_loader`需要正确配置hadoop库文件，包括hdfs、mapreduce、hive等所有jar包. 我的配置为:
```
common.loader=${catalina.base}/lib,\ 
${catalina.base}/lib/*.jar,\ 
${catalina.home}/lib,\ 
${catalina.home}/lib/*.jar,\ 
${catalina.home}/../lib/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop/lib/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop-hdfs/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop-hdfs/lib/*.jar,\ /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/lib/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop-yarn/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hadoop-yarn/lib/*.jar,\ 
/opt/cloudera/parcels/CDH/lib/hive/lib/*.jar
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

自带derby版本过低运行时会由于不兼容而出现以下错误：
```
org.apache.sqoop.common.SqoopException: JDBCREPO_0007:Unable to lease link
at org.apache.sqoop.repository.JdbcRepositoryTransaction.begin(JdbcRepositoryTransaction.java:63)
	at org.apache.sqoop.repository.JdbcRepository.doWithConnection(JdbcRepository.java:85)
	at org.apache.sqoop.repository.JdbcRepository.doWithConnection(JdbcRepository.java:61)
	at org.apache.sqoop.repository.JdbcRepository.createOrUpgradeRepository(JdbcRepository.java:127)
	at org.apache.sqoop.repository.RepositoryManager.initialize(RepositoryManager.java:123)
	at org.apache.sqoop.tools.tool.UpgradeTool.runToolWithConfiguration(UpgradeTool.java:39)
	at org.apache.sqoop.tools.ConfiguredTool.runTool(ConfiguredTool.java:35)
	at org.apache.sqoop.tools.ToolRunner.main(ToolRunner.java:75)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:606)
	at org.apache.sqoop.tomcat.TomcatToolRunner.main(TomcatToolRunner.java:77)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:606)
	at org.apache.catalina.startup.Tool.main(Tool.java:225)
Caused by: java.sql.SQLException: No suitable driver found for 
```

解决办法为[下载derby](http://db.apache.org/derby/derby_downloads.html)最新版本，先删除`/sqoop-1.99.6-bin-hadoop200/server/webapps/sqoop/WEB-INF/lib`下的derby旧包，然后把新下载的derby目录下的lib下的jar包拷贝到`/sqoop-1.99.6-bin-hadoop200/server/webapps/sqoop/WEB-INF/lib`

## 5. 验证

运行bin/sqoop2-shell,进入sqoop shell模式, 运行`show version --all`，若能正确输出server版本，则安装成功:
```
sqoop:000> show version --all
client version:
  Sqoop 1.99.6 source revision 07244c3915975f26f03d9e1edf09ab7d06619bb8
  Compiled by root on Wed Apr 29 10:40:43 CST 2015
server version:
  Sqoop 1.99.6 source revision 07244c3915975f26f03d9e1edf09ab7d06619bb8
  Compiled by root on Wed Apr 29 10:40:43 CST 2015
API versions:
  [v1]
```
