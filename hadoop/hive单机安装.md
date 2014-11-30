# hive单机安装

## 安装要求

1. java1.7+
2. hadoop2.x
3. mysql5.5+(非必须，建议使用mysql存储元数据)

## 安装前的环境

1. JAVA_HOME: java安装目录
2. HADOOP_HOME: hadoop安装目录
3. CLASSPATH: 除了hadoop和hive的必须包，还需要包括mysql java驱动，这里使用的是mysql-connector-java-5.1.25.jar，
并把它放入到lib下

## 安装过程

### Step 1 下载tar包

在[hive官网](http://www.apache.org/dyn/closer.cgi/hive/)下载最新的tar包，当前最新包为apache-hive-0.14.0-bin.tar.gz。

### Step 2 解压包

假定安装路径为/opt/hive：
```bash
sudo mv apache-hive-0.14.0-bin.tar.gz /opt
sudo tar xvf apache-hive-0.14.0-bin.tar.gz
sudo ln -s apache-hive-0.14.0-bin hive
sudo mv mysql-connector-java-5.1.25.jar /opt/hive/lib
```
### Step 3 配置
* 创建配置文件，直接从模板文件创建即可
```bash
sudo rename 's/\.template//' *
sudo touch hive-site.xml
```
* 编辑hive-env.sh文件，设置HADOOP_HOME=${HADOOP_HOME-:/opt/hadoop}
* 创建hive-site-xml文件，添加以下内容:
```xml
<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:mysql://localhost:3306/metastore?createDatabaseIfNotExist=true</value>
  <description>the URL of the MySQL database</description>
</property>

<property>
  <name>javax.jdo.option.ConnectionDriverName</name>
  <value>com.mysql.jdbc.Driver</value>
</property>

<property>
  <name>javax.jdo.option.ConnectionUserName</name>
  <value>hive</value>
</property>

<property>
  <name>javax.jdo.option.ConnectionPassword</name>
  <value>HIVE_DBPASS</value>
</property>

<property>
  <name>datanucleus.autoCreateSchema</name>
  <value>true</value>
</property>

<property>
  <name>datanucleus.fixedDatastore</name>
  <value>false</value>
</property>

<property>
  <name>datanucleus.autoCreateTables</name>
  <value>true</value>
</property>

<property>
  <name>datanucleus.autoCreateColumns</name>
  <value>true</value>
</property>

<property>
  <name>datanucleus.autoStartMechanism</name> 
  <value>SchemaTable</value>
</property> 
 
<property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/user/hive/warehouse</value>
</property>

<!--
<property>
  <name>hive.metastore.uris</name>
  <value>thrift://localhost:9083</value>
  <description>IP address (or fully-qualified domain name) and port of the metastore host</description>
</property>

<property>
  <name>hive.aux.jars.path</name>
  <value>file:///opt/hive/lib/zookeeper-3.4.5.jar,file:///opt/hive/lib/hive-hbase-handler-0.14.0.jar,file:///opt/hive/lib/guava-11.0.2.jar</value>
</property>
-->

<property>
 <name>hbase.zookeeper.quorum</name>
<value>localhost</value>
</property>

<property>
  <name>hive.support.concurrency</name>
  <description>Enable Hive's Table Lock Manager Service</description>
  <value>true</value>
</property>

</configuration>
```
* mysql设置。修改/etc/mysql/my.cnf，修改bind-address 为0.0.0.0,重启mysql服务。
* 在hdfs创建必要目录:
```bash
$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp
$HADOOP_HOME/bin/hdfs dfs -mkdir /user/hive
$HADOOP_HOME/bin/hdfs dfs -chown hive /user/hive
$HADOOP_HOME/bin/hdfs dfs -mkdir  /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod g+w   /tmp
$HADOOP_HOME/bin/hdfs dfs -chmod 777   /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod a+t /user/hive/warehouse
```
* 运行$HIVE_HOME/bin/hive, OK!
