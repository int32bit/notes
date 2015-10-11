# 修改sbt和maven镜像源

sbt运行时经常需要下载大量的jar包，默认连接到maven官网，官方默认的镜像，由于各种原因，访问速度极慢，使用国内源会大大提高速度

## 修改sbt镜像源

以使用oschina镜像源为例，在`~/.sbt/`下添加一个`repositories`文件，里面内容如下：
```
[repositories]
local
osc: http://maven.oschina.net/content/groups/public/
typesafe: http://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
sonatype-oss-releases
maven-central
sonatype-oss-snapshots
```

## maven添加方法

修改`/etc/maven/settings.xml`文件，在`<mirrors>`中添加以下内容:
```xml
<mirror>
               <id>CN</id>
                 <name>OSChina Central</name>
                 <url>http://maven.oschina.net/content/groups/public/</url>
                 <mirrorOf>central</mirrorOf>
</mirror>
```
