# 使用moderncv创建个人简历
## 0. 编译环境
* 操作系统ubuntu14.04 64 位
* pdfTeX 3.1415926-2.5-1.40.14 (TeX Live 2013/Debian)
* kpathsea version 6.1.1


## 1. 安装latex 以及必要包
```bash
sudo apt-get install texlive-latex-base
sudo apt-get install texlive-latex-extra
sudo apt-get install latex-cjk-chinese # 支持中文
sudo apt-get install texlive-fonts-recommended texlive-font-extra #安装字体
```
## 2. 下载moderncv

进入官网[modernc](http://www.ctan.org/tex-archive/macros/latex/contrib/moderncv/)下载，解压缩

## 3. 创建个人简历

```bash
cd moderncv && mkdir me
cp examples/template-zh.tex me/me.tex
cd me && cp ../*.sty .

#编译
pdflatex me.tex
```

## 4. 从模版中修改，创建个人简历

修改me.tex,编译成pdf就OK了
