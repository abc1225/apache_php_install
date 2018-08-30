#!/bin/bash
PHP_INI_PATH=/usr/local/lib
PHP_FPM_PATH=/usr/local/etc
PHP_EXTENSION_PATH=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/

# 扩展包更新包  当 libmcrypt-devel libicu-devel libicu 找不到时
yum  install epel-release
yum  update  

#  libmcrypt installed by source code  in rely.sh

# 第二步   Centos 编译安装 PHP 5.6.37
yum install gcc gcc-c++ make autoconf
yum groupinstall "Development tools"
yum install libmcrypt-devel libxml2-devel gd-devel openssl-devel libmcrypt-devel libicu-devel libicu mysql-devel

ln -s /usr/lib64/libmysqlclient.so /usr/lib/
ln -s /usr/lib64/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
ldconfig

#**************libiconv支持字符集转换*************#
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local/libiconv
cd srclib/
sed -ir -e '/gets is a security/d' ./stdio.in.h
cd ../
make && make install
cd ..

# 单独编译 nghttp2s  curl 支持http2 libcurl-devel
# 下载地址 https://curl.haxx.se/download/
yum remove  libcurl-devel

#编译安装nghttp2
git clone https://github.com/tatsuhiro-t/nghttp2.git
cd nghttp2
autoreconf -i
automake
autoconfs
./configure
make
make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig
cd ..

#编译安装curl
wget https://curl.haxx.se/download/curl-7.61.0.tar.gz
tar -xvf curl-7.61.0.tar.gz
cd curl-7.61.0
./configure --prefix=/usr/local --with-nghttp2=/usr/local --with-ssl
make && make install
cd ..


# 从官网下载源码 http://us3.php.net/get/php-5.6.37.tar.gz/from/a/mirror    选择一个美国镜像
wget http://am1.php.net/distributions/php-5.6.37.tar.gz
tar -xvf php-5.6.37.tar.gz
cd php-5.6.37

# 设置配置 注意xml 的交叉编译头文件位置 /usr/include/libxml2
./configure --with-libdir=lib64 --disable-rpath --enable-fpm --enable-shared --enable-bcmath --with-iconv-dir=/usr/local/libiconv --enable-ftp=shared --with-mhash --with-gettext --with-libxml-dir=/usr/include/libxml2 --enable-xml \
--with-gd --enable-gd-native-ttf --with-openssl --enable-mbstring --with-mcrypt --with-mysqli --with-mysql --enable-opcache=shared --enable-mysqlnd --enable-zip=shared --enable-shmop=shared --enable-sysvsem=shared \
--with-zlib-dir --with-pdo-mysql --with-jpeg-dir --with-png-dir --with-freetype-dir=shared --with-curl --enable-inline-optimization=shared --enable-mbregex=shared --enable-mbstring=shared --enable-pcntl=shared --enable-sockets=shared \
--with-xmlrpc --enable-soap=shared --disable-fileinfo --enable-intl


# './configure'  '--prefix=/www/server/php/55' '--with-config-file-path=/www/server/php/55/etc' \
# '--enable-fpm' '--with-fpm-user=www' '--with-fpm-group=www' \
# '--with-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-pdo-mysql=mysqlnd' '--with-iconv-dir' '--with-freetype-dir=/usr/local/freetype' '--with-jpeg-dir' \
# '--with-png-dir' '--with-zlib' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-shmop' '--enable-sysvsem' \
# '--enable-inline-optimization' '--with-curl=/usr/local/curl' '--enable-mbregex' '--enable-mbstring' '--with-mcrypt' '--enable-ftp' '--with-gd' \
# '--enable-gd-native-ttf' '--with-openssl=/usr/local/openssl' '--with-mhash' \
# '--enable-pcntl' '--enable-sockets' '--with-xmlrpc' '--enable-zip' '--enable-soap' '--with-gettext' '--disable-fileinfo' '--enable-opcache' '--enable-intl'

# 安装
make
make install


#*********************必须修改的配置***************************#
# 1. /usr/local/lib/php.ini
#**************************************************************#
# 把php配置文件 拷贝至 /usr/local/lib/php.ini
cd ..
cp php.ini $PHP_INI_PATH/php.ini
chmod 777 $PHP_INI_PATH/php.ini

#配置php.ini 文件
# sed -i "s#expose_php = On#expose_php = Off#g" $PHP_INI_PATH/php.ini
# sed -i "s#max_execution_time = 30#max_execution_time = 300#g" $PHP_INI_PATH/php.ini
# sed -i "s#max_input_time = 60#max_input_time = 600#g" $PHP_INI_PATH/php.ini
# sed -i "s#;error_log = php_errors.log#error_log = /usr/local/php/var/log/php_errors.log#g" $PHP_INI_PATH/php.ini
# sed -i "s#post_max_size = 8M#post_max_size = 100M#g" $PHP_INI_PATH/php.ini
# sed -i "s#;cgi.fix_pathinfo=1#cgi.fix_pathinfo=0#g" $PHP_INI_PATH/php.ini
# sed -i "s#;upload_tmp_dir =#upload_tmp_dir = /tmp#g" $PHP_INI_PATH/php.ini
# sed -i "s#;date.timezone =#date.timezone = Europe/London#g" $PHP_INI_PATH/php.ini
# #sed -i "s#;date.timezone =#date.timezone = Asia/Tokyo#g" $PHP_INI_PATH/php.ini
# sed -i 's#expose_php = On@expose_php = Off#g' $PHP_INI_PATH/php.ini

# #并为php添加共享链接库，在php.ini最后添加
# sed -i '$a\extension=ftp.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=mbstring.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=pcntl.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=shmop.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=soap.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=sockets.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=sysvsem.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=zip.so' $PHP_INI_PATH/php.ini
# sed -i '$a\extension=redis.so' $PHP_INI_PATH/php.ini
# sed -i '$a\zend_extension=ZendGuardLoader.so' $PHP_INI_PATH/php.ini
# sed -i '$a\zend_extension=opcache.so' $PHP_INI_PATH/php.ini


# 让php-fpm的配置文件生效
#cp /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf
# ***************修改php-fpm.conf配置文件************

# user = daemon
# group = daemon
# listen = /dev/shm/php-fpm.sock
# listen.owner = daemon
# listen.group = daemon
# pm = static
# pm.max_children = 4 ；见下面解释
# pm.max_requests = 2048

#添加PHP-FPM的配置文件
cp php-fpm.conf $PHP_FPM_PATH/php-fpm.conf
chmod 777 $PHP_FPM_PATH/php-fpm.conf
 
#说明： pm.max_children, pm.start_servers, pm.min_spare_servers, pm.max_spare_servers 
#这几个参数的值可以根据服务器内存的大小来调整，内存大的，设置的值就大
#公式 pm.start_servers = min_spare_servers + (max_spare_servers - min_spare_servers) / 2
#  pm.max_children 的值 如果是多核cpu的vps或者服务器，上面的数值等于cpu数量即可；如果是单核的vps，那么pm.max_children = 2，即可达到一定的优化效果
 
#配置php-fpm.conf
# sed -i "s#;pid = run/php-fpm.pid#pid = run/php-fpm.pid#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;error_log#error_log#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;log_level = notice#log_level = warning#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#; process.max = 128#process.max = 128#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;slowlog#slowlog#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;events.mechanism = epoll#events.mechanism = epoll#g" $PHP_FPM_PATH/php-fpm.conf

# # 配置php-fpm进程开启模式  
# sed -i "s#pm = dynamic#pm = static#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#pm.max_children = 5#pm.max_children = 8#g" $PHP_FPM_PATH/php-fpm.conf
# # used on when use dynamic pm model
# sed -i "s#pm.start_servers = 2#pm.start_servers = 4#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#pm.min_spare_servers = 1#pm.min_spare_servers = 2#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#pm.max_spare_servers = 3#pm.max_spare_servers = 5#g" $PHP_FPM_PATH/php-fpm.conf

# # max requests: php-fpm process restart 
# sed -i "s#;pm.max_requests = 500#pm.max_requests = 2000#g" $PHP_FPM_PATH/php-fpm.conf

# sed -i "s#;listen.allowed_clients#listen.allowed_clients#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#user = nobody#user = daemon#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#group = nobody#group = daemon#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#listen = 127.0.0.1:9000#listen = 127.0.0.1:9000\n;listen = /tmp/php-cgi.sock#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;listen.owner = nobody#listen.owner = daemon#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;listen.group = nobody#listen.group = daemon#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;listen.mode = 0666#listen.mode = 0666#g" $PHP_FPM_PATH/php-fpm.conf

# # config log
# sed -i "s#;slowlog#slowlog#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;access.format#access.format#g" $PHP_FPM_PATH/php-fpm.conf
# sed -i "s#;access.log = log/$pool.access.log#access.log = /usr/local/php/var/log/$pool.access.log#g" $PHP_FPM_PATH/php-fpm.conf




# 开机自动启动php-fpm
cp ./init.d/php-fpm /etc/init.d/php-fpm
chmod 777 /etc/init.d/php-fpm

#**************Zend Guard Loader支持加密*************#
/usr/local/bin/pecl install swoole-1.10.5
/usr/local/bin/pecl install redis
/usr/local/bin/pecl install mongo
/usr/local/bin/pecl install mongodb



wget http://downloads.zend.com/guard/7.0.0/zend-loader-php5.6-linux-x86_64_update1.tar.gz
tar zxvf zend-loader-php5.6-linux-x86_64_update1.tar.gz
cd zend-loader-php5.6-linux-x86_64
cp ZendGuardLoader.so $PHP_EXTENSION_PATH
cd ..




# 开机自动启动php-fpm
chmod o+x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
service php-fpm start


#*********************************PHP配置结束********************************#




#*********************************以下为PHP输出配置********************************#
# php -m

#[PHP Modules]
#bcmath
#Core
#ctype
#curl
#date
#dom
#ereg
#filter
#ftp
#gd
#gettext
#hash
#iconv
#intl
#json
#libxml
#mbstring
#mcrypt
#mhash
#mongo
#mongodb
#mysql
#mysqli
#mysqlnd
#openssl
#pcntl
#pcre
#PDO
#pdo_mysql
#pdo_sqlite
#Phar
#posix
#redis
#Reflection
#session
#shmop
#SimpleXML
#soap
#sockets
#SPL
#sqlite3
#standard
#swoole
#sysvsem
#tokenizer
#xml
#xmlreader
#xmlrpc
#xmlwriter
#Zend Guard Loader
#Zend OPcache
#zip
#zlib

#[Zend Modules]
#Zend Guard Loader
#Zend OPcache
