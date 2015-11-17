# 使用Docker部署Gitlab

## 1. 下载gitlab镜像

```bash
docker pull gitlab/gitlab-ce
```
## 2. 运行gitlab实例

```bash
GITLAB_HOME=`pwd`/data/gitlab
docker run -d \
    --hostname gitlab \
    --publish 8443:443 --publish 80:80 --publish 2222:22 \
    --name gitlab \
    --restart always \
    --volume $GITLAB_HOME/config:/etc/gitlab \
    --volume $GITLAB_HOME/logs:/var/log/gitlab \
    --volume $GITLAB_HOME/data:/var/opt/gitlab \
    gitlab/gitlab-ce
```

## 3. 配置gitlab实例

主要是需要配置邮箱:

```bash
docker exec -t -i gitlab vim /etc/gitlab/gitlab.rb
```
下面以网易163邮箱为例配置邮箱:

```
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_user_name'] = "xxxx@163.com"
gitlab_rails['smtp_password'] = "xxxxpassword"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = false
gitlab_rails['smtp_openssl_verify_mode'] = "peer"

gitlab_rails['gitlab_email_from'] = "xxxx@163.com"
user["git_user_email"] = "xxxx@163.com"
```

注意以上的`xxxx@163.com`代表用户名，即邮箱地址，而`xxxxpassword`不是邮箱的登陆密码而是网易邮箱的**客户端授权密码**, 再网易邮箱web页面的`设置-POP3/SMTP/IMAP-客户端授权密码`查看。

## 4. 重启gitlab

```bash
docker restart gitlab
```
