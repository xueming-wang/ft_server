# docker + wordpress搭建个人站点
#基于Linux下Debian系统 容器在这个系统内运行  Le container devra tourner avec Debian Buster.
FROM debian:buster   

# 复制当前所有文件包括文件夹到容器里的/tmp文件夹里
COPY . /tmp
# 指定接下里的工作路径为/tmp
WORKDIR /tmp


# 安装wget mariadb nginx php  #mettre en place un serveur web avec Nginx使用nginx设置服务器
RUN apt-get update \
    && apt-get -y install openssl \
    && apt-get -y install wget \
    && apt-get -y install mariadb-client mariadb-server \
    && apt-get -y install nginx \                     
    && apt-get -y install php7.3-cli php7.3-fpm php7.3-mysql php7.3-json php7.3-opcache \
    php7.3-mbstring php7.3-xml php7.3-gd php7.3-curl

   
# 创建SSL
RUN mkdir /etc/nginx/ssl \
    && openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem -subj "/C=FR/ST=PARIS/L=paris/O=42/OU=42/CN=xue/emailAddress=wxueming0614@hotmail.com" 


# 配置叫wordpress的数据管理系统
    # 创建数据库
    # 创建数据库用户 : % -> 任何主机都可以访问
    # 给予用户权限
    # 更新信息 
RUN service mysql start \
    && echo "create database wordpress;" | mysql -u root  \
    && echo "create user 'wordpress'@'%';" | mysql -u root \
    && echo "grant all privileges on wordpress.* to 'wordpress'@'%' with grant option;" | mysql -u root \
    && echo "flush privileges;" | mysql -u root

# 下载配置phpmadmin
RUN mkdir /var/www/site/ \
    && wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.tar.gz \
    && tar -xvzf phpMyAdmin-5.1.0-all-languages.tar.gz \
    && mv phpMyAdmin-5.1.0-all-languages /var/www/site/phpmyadmin \
    && mv /tmp/srcs/config.inc.php /var/www/site/phpmyadmin \
    && chown -R www-data: /var/www/site/phpmyadmin
    

# 下载配置wordpress
RUN wget http://wordpress.org/latest.tar.gz \
    && tar -xzvf latest.tar.gz \    
    && mv wordpress /var/www/site/wordpress \
    && mv /tmp/srcs/wp-config.php /var/www/site/wordpress \
    && chown -R www-data: /var/www/site/wordpress

# 配置nginx
RUN rm -rf /etc/nginx/sites-enabled/default \
    && cp /tmp/srcs/mynginxconf /etc/nginx/sites-available \
    && ln -s /etc/nginx/sites-available/mynginxconf /etc/nginx/sites-enabled/



CMD bash ./srcs/init.sh
#启动容器时执行的Shell命令 启动容器时执行的脚本文件 CMD 在docker run 时运行。