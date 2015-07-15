# 配置spark-streaming读取flume数据

## 1.依赖配置

由于我们使用`sbt`构建项目，因此所有依赖库写入`build.sbt`的`libraryDependencies`即可，格式
为`groupId % artifactId % version`，具体字段含义建议参考maven.

我们这次代码除了需要`spark-core`外，还需要第三方库`spark-streaming-flume`,因此`build.sbt`
大致内容为:

```scala
name := "FlumeEventCount"

version := "1.0"

scalaVersion := "2.10.4"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.4.0"

libraryDependencies += "org.apache.spark" % "spark-streaming_2.10" % "1.4.0"

libraryDependencies += "org.apache.spark" % "spark-streaming-flume_2.10" % "1.4.0"
```
<font color='red'>注意`build.sbt`行与行之间要有空行，这是语法要求！</font>

## 2.测试代码

通过调用`FlumeUtils.createStream()`方法创建flume流，本次测试仅仅统计每次(每隔2秒)获取
的数据行数(事件数)，代码为:

```scala
package com.huawei.test

import org.apache.spark.SparkConf
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming._
import org.apache.spark.streaming.flume._
import org.apache.spark.util.IntParam

/**
 *  Produces a count of events received from Flume.
 *
 *  This should be used in conjunction with an AvroSink in Flume. It will start
 *  an Avro server on at the request host:port address and listen for requests.
 *  Your Flume AvroSink should be pointed to this address.
 *
 *  Usage: FlumeEventCount <host> <port>
 *    <host> is the host the Flume receiver will be started on - a receiver
 *           creates a server and listens for flume events.
 *    <port> is the port the Flume receiver will listen on.
 *
 *  To run this example:
 *    `$ bin/run-example org.apache.spark.examples.streaming.FlumeEventCount <host> <port> `
 */
object FlumeEventCount{
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println(
        "Usage: FlumeEventCount <host> <port>")
      System.exit(1)
    }

    val host = args(0)
    val port = args(1).toInt

    val batchInterval = Milliseconds(2000)

    // Create the context and set the batch size
    val sparkConf = new SparkConf().setAppName("FlumeEventCount")
    val ssc = new StreamingContext(sparkConf, batchInterval)

    // Create a flume stream
    val stream = FlumeUtils.createStream(ssc, host, port, StorageLevel.MEMORY_ONLY_SER_2)

    // Print out the count of events received from this server in each batch
    stream.count().map(cnt => "Received " + cnt + " flume events." ).print()

    ssc.start()
    ssc.awaitTermination()
  }
}
```

## 3.配置flume

只需要把sink配置成SparkSink即可
```conf
agent.sinks = spark
agent.sinks.spark.type = org.apache.spark.streaming.flume.sink.SparkSink
agent.sinks.spark.hostname = <hostname of the local machine>
agent.sinks.spark.port = <port to listen on for connection from Spark>
agent.sinks.spark.channel = memoryChannel
 ```

 ## 4.打包程序

 ```bash
cd $PROJECT_ROOT # PROJECT_ROOT为项目根路径，即build.sbt的位置
ant package
 ```

 ## 5.运行

 注意：除了`spark-core`依赖包会由`spark-submit`自动引入，其他依赖包比如
 `spark-streaming-flume`必须手动引入:
 * 设置`CLASSPATH`,把依赖包放入CLASSPATH中
 * 使用`--jars`参数手动加入

此次测试采用后种方法，即使用`--jars`参数。这个工程只差`spark-streaming-flume`包，sbt编译
时已经自动下载到本地，位于`~/.ivy2/cache/org.apache.spark/spark-streaming-flume_2.10/jars`,
把所有的jar包复制到工程的lib目录下.

```bash
cp ~/.ivy2/cache/org.apache.spark/spark-streaming-flume_2.10/jars/*.jar lib
```

使用spark-submit 提交程序，为了避免每次重复输入命令，写一个脚本用于提交:
```bash
#!/bin/sh
spark-submit --master local[*] --class com.huawei.test.FlumeEventCount\
--jars lib/*.jar\
target/scala-2.10/flumeeventcount_2.10-1.0.jar localhost 50000
```
其中`localhost`表示flume写入的主机名，`50000`表示flume写入端口

## 6.运行结果

当flume有数据流时，程序会捕捉事件，统计每次的事件总数。

## 6.运行结果

当flume有数据流时，程序会捕捉事件，统计每次的事件总数。
```
-------------------------------------------
Time: 1436942874000 ms
-------------------------------------------
Received 1345 flume events.

-------------------------------------------
Time: 1436942876000 ms
-------------------------------------------
Received 2132 flume events.

-------------------------------------------
Time: 1436942878000 ms
-------------------------------------------
Received 0 flume events.

```
