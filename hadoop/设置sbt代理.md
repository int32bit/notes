# 设置sbt代理

sbt默认并不读取环境变量`http_proxy`,而是使用java系统属性(property), 我们使用`SBT_OPTS`
进行设置，具体如下:
```bash
SBT_OPTS="$SBT_OPTS -Dhttp.proxyHost=proxyhk.huawei.com\
 -Dhttp.proxyPort=8080\
 -Dhttp.proxyUser=CHINA\\hWX275716 -Dhttp.proxyPassword=password"
```
需要注意一下几点:
* `http_proxyHost`**只需要设置代理主机名，不需要协议名**，不能在前面有`http://`或者`https://`
* `http_proxyUser`使用域账户名时，**务必切记需要转义`\`字符**，需要输入两个`\\`
* 建议把值放入引号内，尤其是密码包含`#`字符时，若没有引号，后面会当作注释而截取掉

`SBT_OPTS`需要export，务必保证sbt能够读取到，为了简易，可以直接编辑`bin/sbt`文件，在开头
加上:
```sh
export SBT_OPTS="$SBT_OPTS -Dhttp.proxyHost=proxyhk.huawei.com\
 -Dhttp.proxyPort=8080\
 -Dhttp.proxyUser=CHINA\\hWX275716 -Dhttp.proxyPassword=password"
```

验证是否成功:

```bash
sbt -v # 使用-v参数，输出系统变量
```
输出：

```
[process_args] java_version = '1.7.0_55'
# Executing command line:
java
-Dhttp.proxyHost=proxyhk.huawei.com
-Dhttp.proxyPort=8080
-Dhttp.proxyUser=CHINA\hWX275716
-Dhttp.proxyPassword=password
-Xms1024m
-Xmx1024m
-XX:ReservedCodeCacheSize=128m
-XX:MaxPermSize=256m
-jar
/home/fgp/sbt/bin/sbt-launch.jar
```
**请务必检查以上java属性是否设置正确**，如果是第一次运行，会先下载sbt版本依赖库，可能堵塞几分钟，
需要耐心等下，如果没有抛超时异常，则说明配置成功！
