# 构建hadoop2.5.2环境下的spark1.1.1

当前已编译的spark二进制包只有hadoop2.4和cdh4版本的，如果搭的是hadoop2.5.x，则需要自己从源码中构建。

## 下载源码

从[官网](spark.apache.org/downloads.html)中下载源码，在**Chose a package type** 中选择**Source Code**, 下载后解压缩。
```bash
tar xvf spark-1.1.1.tgz
```

## 编译

### Step1 设置maven内存限制

```bash
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
```

### Step2 增加hadoop-2.5的profile

注意hadoop版本2.x.x需要指定profile，在根下的pom.xml下只有2.4.0的profile，
如果要在hadoop-2.5.x下，需要手动加上hadoop-2.5的profile，即添加pom.xml：
```xml
 <profile>
      <id>hadoop-2.5</id>
      <properties>
        <hadoop.version>2.5.2</hadoop.version>
        <protobuf.version>2.5.0</protobuf.version>
        <jets3t.version>0.9.0</jets3t.version>
      </properties>
    </profile>
```
否则编译的结果得到的protobuf版本不对，无法读取hdfs上的文件，抛java.lang.VerifyError: class org.apache.hadoop.hdfs
.protocol.proto.ClientNamenodeProtocolProtos$CreateSnapshotRequestProto overrides final method getUnknownFields.()
Lcom/google/protobuf/UnknownFieldSet;

### Step3 编译

运行:
```bash
mvn -Pyarn -Phadoop-2.5 -Dhadoop.version=2.5.2 -Phive -DskipTests clean package
```
