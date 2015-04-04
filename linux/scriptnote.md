## 1. 删除所有的换行符和空格符

```bash
sed  -e ':a;N;s/\n//;s/ //g;ba' test.txt
```
or

```bash
cat test.txt | tr -d '\n '
```

## 2. spark on hive

* spark编译了hive
* 必须把hive-site.xml 复制到spark配置目录中
* 必须把hive使用的元数据库的驱动加入到SPARK_CLASSPATH中
