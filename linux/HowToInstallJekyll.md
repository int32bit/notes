## ubuntu14.04 安装jekyll

注意不要使用apt-get直接安装jekyll，默认是老版本的，运行不了。

首先需要安装依赖包，注意不仅要安装ruby，还需要ruby-dev和nodejs
```bash
sudo apt-get install ruby ruby-dev make gcc nodejs
```

然后使用gem 安装jekyll
```bash
sudo gem install jekyll --no-rdoc --no-ri
```

但是会出现
```
ERROR:  While executing gem ... (NoMethodError)
    undefined method `size' for nil:NilClass
```
解决方法是删除cache文件，
```
krystism@lenovo:~/notes/linux$ gem env
RubyGems Environment:
  - RUBYGEMS VERSION: 1.8.23
  - RUBY VERSION: 1.9.3 (2013-11-22 patchlevel 484) [x86_64-linux]
  - INSTALLATION DIRECTORY: /var/lib/gems/1.9.1
  - RUBY EXECUTABLE: /usr/bin/ruby1.9.1
  - EXECUTABLE DIRECTORY: /usr/local/bin
  - RUBYGEMS PLATFORMS:
    - ruby
    - x86_64-linux
  - GEM PATHS:
     - /var/lib/gems/1.9.1
     - /home/fgp/.gem/ruby/1.9.1
  - GEM CONFIGURATION:
     - :update_sources => true
     - :verbose => true
     - :benchmark => false
     - :backtrace => false
     - :bulk_threshold => 1000
  - REMOTE SOURCES:
     - http://rubygems.org/
```
得到`GEM PATHS`, 进去删除cache文件。
