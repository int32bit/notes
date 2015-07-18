# nutch集成solr和中文分词

## 一、构建nutch环境

### 1. 设置代理

由于nutch使用ant构建，ant调用ivy，会从maven仓库中下载依赖包，因此若公司需要代理才能上网，需要设置代理，***如果公司不需要代理即可上网，此步骤直接省略.***

总结设置代理遇到的几个坑：

* 强制使用系统代理,即 ant -autoproxy , 结果失败!
* 修改 build.xml , 增加 setproxy ,设置代理,结果失败!
* 设置 ANT_OPTS ,添加选项
* -Dhttp.proxyHost=http://proxy01.cd.intel.com
* -Dhttp.proxyPort=911 , 结果失败!
* 传递 http_proxy ,结果失败!

失败原因: <font color="red">`proxyHost`只需要包括主机名，而不需要指定协议</font>

成功编译为修改`build.xml`文件，设置代理，内容如下:

```xml
<target name="myproxy">
	  <setproxy proxyhost="child-prc.intel.com" proxyport="913" />
</target>
```

并修改`ivy-init`指令，如下:
```xml
<target name="ivy-init" depends="ivy-probe-antlib, ivy-init-antlib,myproxy" description="--> initialise Ivy settings">
    <ivy:settings file="${ivy.dir}/ivysettings.xml" />
</target>
```

### 2. 设置hadoop环境

***若只是构建单机模式，此步骤省略!***

否则需要设置并`export HADOOP_HOME`环境变量:

```bash
export HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop}
echo $HADOOP_HOME
```
### 3. nutch配置
在编译之前首先需要配置nutch，***每次更新配置文件，都需要重新编译！***
配置文件位于`$NUTCH_HOME/conf`下，务必设置`http.agent.name`,否则编译后不能运行, 编辑`conf/nutch-site.xml`, 内容为:
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
	<property>
		<name>http.agent.name</name>
		<value>My Spider</value>
	</property>
</configuration>
```

如果需要设置nutch运行时代理，需要配置代理,修改文件`$NUTCH_HOME/conf/nutch-default.xml`, 修改`http.proxyHost`和`http.proxyPort`值，内容如下:
```xml
<property>
  <name>http.proxy.host</name>
  <value>proxy01.cd.intel.com</value>
  <description>The proxy hostname.  If empty, no proxy is used.</description>
</property>

<property>
  <name>http.proxy.port</name>
  <value>911</value>
  <description>The proxy port.</description>
</property>
```

### 4.编译构建nutch
<font color='red'>在此之前，请确保以上步骤已经正确完成，否则会导致编译失败或者运行失败！</font>
编译:
```bash
ant -v runtime
```
构建开始，大约需要30分钟的时间
## 二、集成solr

目前solr的版本是5.x,但好像5.x版本差别较大，nutch没有集成支持！因此我们使用当前的4.x版本，目前该版本的latest是4.10.4,点击[此处下载](http://www.carfab.com/apachesoftware/lucene/solr/4.10.4/solr-4.10.4.tgz).

### 1.初始化

解压缩，复制example/solr/collection1下的core `collection1`为`nutch`:

```bash
cp -rf collection1 nutch
```
并修改`$SOLR_HOME/example/solr/nutch/core.properties`文件，设置name为nutch:
```
name=nutch
```

 把`$NUTCH_HOME/conf/schema-solr4.xml`复制到`$SOLR_HOME/example/solr/nutch/conf`下,并重命名为`schema.xml`:

```bash
cp $NUTCH_HOME/conf/schema-solr4.xml  $SOLR_HOME/example/solr/nutch/conf/schema.xml
```

### 2. 修改配置

此时启动solr会出现以下错误:
```
org.apache.solr.common.SolrException:org.apache.solr.common.SolrException: copyField dest :'location' is not an explicit field and doesn't match a dynamicField
```
应该是配置文件schema.xml的一个bug, 修复办法为在`<fields>`下增加一个location `field`， 内容为:
```
  <field name="location" type="location" stored="false" indexed="true" multiValued="true"/>
```


若没有`_version`属性，则增加`_version_`属性:
```
<field name="_version_" type="long" indexed="true" stored="true"/>
```
### 3. 增加中文分词
首先从google code上下载[IKAnalyzer](http://code.google.com/p/ik-analyzer/downloads/list),下载版本为`IK Analyzer 2012FF_hf1.zip`,如果被GFW， 点击[此处下载](./resources).
解压缩文件，把IKAnalyzer2012FF_u1.jar文件复制到`$SOLR_HOME/example/solr-webapp/webapp/WEB-INF/lib`,把IKAnalyzer.cfg.xml和stopword.dic复制到`$SOLR_HOME/example/solr/nutch/conf`,与schema.xml一个目录下:

```bash
cp IKAnalyzer2012FF_u1.jar $SOLR_HOME/example/solr-webapp/webapp/WEB-INF/lib
cp IKAnalyzer.cfg.xml stopword.dic $SOLR_HOME/example/solr/nutch/conf
```

修改core的schema.xml，在<types></types>配置项间加一段如下配置：
```xml
<fieldType name="text_cn" class="solr.TextField">   
     <analyzer class="org.wltea.analyzer.lucene.IKAnalyzer"/>   
</fieldType>
```
在这个core的schema.xml里面配置field类型的时候就可以使用text_cn
```xml
<field name="name"      type="text_cn"   indexed="true"  stored="true"  multiValued="true" /> 
```
启动solr服务
```sh
cd $SOLR_HOME/example
java -jar start.jar
```
浏览器访问[http://172.16.182.23:8983/solr/#/nutch](http://172.16.182.23:8983/solr/#/nutch)，在左下边点击`Analysis`连接，选择`Analyse Fieldname / FieldType`为`text_cn`,在`Field Value (Index)`下输入:
```
我喜欢solr
```
然后点击蓝色按钮`Analyse Values`,查看效果，看是否正确分词！

## 三、单机运行测试

具体过程可以查看[官方教程](https://wiki.apache.org/nutch/NutchTutorial) 。

总结过程如下:

### 1. 创建种子列表
```sh
mkdir urls
cd urls
touch seeds.txt
echo "http://nutch.apache.org/" >> seeds.txt # 每行一个URL
```

### 2.使用`crawl`脚本运行

```sh
bin/crawl -i -D solr.server.url=http://localhost:8983/solr/nutch urls/ TestCrawl/  2
```

### 3. 验证结果

打开[http://localhost:8983/solr/](http://localhost:8983/solr/)，点击`solr admin`, 在`Querty String`输入`nutch`, 点击`Search`查看效果

## 四、分布式运行

与单机过程类型，首先创建`urls`目录作为种子url，然后上传到hdfs上:
```sh
mkdir urls
cd urls
echo "http://apache.org" >>seeds.txt
hdfs dfs -put urls
```
假定solr已经配置完成，url为`localhost:8983`

运行以下命令运行：
```sh
cd $NUTCH_HOME/runtime/runtime/deploy/
bin/crawl -i -D solr.server.url=http://localhost:8983/solr/nutch urls/ TestCrawl/  2
```


