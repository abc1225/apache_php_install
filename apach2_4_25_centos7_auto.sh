#!/bin/bash

APACHE_CONF_PATH=/usr/local/apache2/conf

# 第一步   Centos 编译安装 Apache 2.4
yum groupinstall "Development tools"

yum install zlib-devel pcre-devel

wget http://archive.apache.org/dist/httpd/httpd-2.4.25.tar.gz
wget http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
wget http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz


tar -xvf httpd-2.4.25.tar.gz
tar -xvf apr-1.5.2.tar.gz
tar -xvf apr-util-1.5.4.tar.gz

mv apr-1.5.2 httpd-2.4.25/srclib/apr
mv apr-util-1.5.4 httpd-2.4.25/srclib/apr-util
cd httpd-2.4.25

# 默认就有 --enable-mods-shared=most ，模块化安装，以后自行到 httpd.conf 中决定是否开启模块
./configure --with-included-apr --enable-nonportable-atomics=yes --enable-mods-shared=most --with-mpm=prefork --with-z --enable-ssl


# 安装完毕后， 所有的东西都在 /usr/local/apache2 这个目录下，最重要 conf/httpd.conf ，
make && make install


# 其它自行配置   /usr/local/apache2/conf/extra 下的
# httpd-vhosts.conf（虚拟主机）   
# httpd-mpm.conf  （多处理模块）
# httpd-default.conf（timeout, keepalive）
# httpd-userdir.conf （配置网站目录的）
cd ..
mv /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/httpd.conf.bak
cp conf/httpd.conf /usr/local/apache2/conf/httpd.conf 

mv /usr/local/apache2/conf/extra/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf.bak
cp conf/httpd-vhosts.conf  /usr/local/apache2/conf/extra/httpd-vhosts.conf

mv /usr/local/apache2/conf/extra/httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf.bak
cp conf/httpd-ssl.conf  /usr/local/apache2/conf/extra/httpd-ssl.conf

cp conf/server.crt /usr/local/apache2/conf/server.crt
cp conf/server.key /usr/local/apache2/conf/server.key

#*********************必须修改的配置***************************#
# 1. conf/httpd.conf ServerName配置 并开启 vhosts  开启mod_proxy.so mod_proxy_fcgi.so(支持FPM)
# 	如果php-fpm使用的是TCP socket，那么在httpd.conf末尾加上
#    <FilesMatch \.php$>
#         SetHandler "proxy:fcgi://127.0.0.1:9000"
#	</FilesMatch>
#    如果用的是unix socket，那么httpd.conf末尾加上
#    <Proxy "unix:/dev/shm/php-fpm.sock|fcgi://php-fpm">
# 		ProxySet disablereuse=off
#	 </Proxy>

# 	<FilesMatch \.php$>
# 		SetHandler proxy:fcgi://php-fpm
# 	</FilesMatch>
# 2. httpd-vhosts.conf 配置实例进行测试
#**************************************************************#
#sed -i '$a\<FilesMatch \.php$>' $APACHE_CONF_PATH/httpd.conf
#sed -i '$a\     SetHandler "proxy:fcgi://127.0.0.1:9000"' $APACHE_CONF_PATH/httpd.conf
#sed -i '$a\</FilesMatch>' $APACHE_CONF_PATH/httpd.conf



# 把新编译安装的 Apache 2.4.6 拷贝到位
cp ./init.d/httpd /etc/init.d/httpd
chmod 777 /etc/init.d/httpd

# ***************编辑 /etc/init.d/httpd 文件，在首行 #!/bin/sh 下面加入两行************
# chkconfig: 35 85 15
# description: Activates/Deactivates Apache 2.4.25

chkconfig --add httpd
chkconfig httpd on
service httpd start



#***************************配置HTTPS*************#
#开启  http.conf  socache_shmcb_module 模块


#*********************************以下为Apache输出配置********************************#

# /usr/local/apache2/bin/httpd -V
# 
# Server version: Apache/2.4.25 (Unix)
# Server built:   Jun 21 2018 11:06:42
# Server's Module Magic Number: 20120211:67
# Server loaded:  APR 1.5.2, APR-UTIL 1.5.4
# Compiled using: APR 1.5.2, APR-UTIL 1.5.4
# Architecture:   64-bit
# Server MPM:     prefork
#   threaded:     no
#     forked:     yes (variable process count)
# Server compiled with....
#  -D APR_HAS_SENDFILE
#  -D APR_HAS_MMAP
#  -D APR_HAVE_IPV6 (IPv4-mapped addresses enabled)
#  -D APR_USE_SYSVSEM_SERIALIZE
#  -D APR_USE_PTHREAD_SERIALIZE
#  -D SINGLE_LISTEN_UNSERIALIZED_ACCEPT
#  -D APR_HAS_OTHER_CHILD
#  -D AP_HAVE_RELIABLE_PIPED_LOGS
#  -D DYNAMIC_MODULE_LIMIT=256
#  -D HTTPD_ROOT="/usr/local/apache2"
#  -D SUEXEC_BIN="/usr/local/apache2/bin/suexec"
#  -D DEFAULT_PIDLOG="logs/httpd.pid"
#  -D DEFAULT_SCOREBOARD="logs/apache_runtime_status"
#  -D DEFAULT_ERRORLOG="logs/error_log"
#  -D AP_TYPES_CONFIG_FILE="conf/mime.types"
#  -D SERVER_CONFIG_FILE="conf/httpd.conf"
#  
#  
#  /usr/local/apache2/bin/httpd -M
# Loaded Modules:
#  core_module (static)
#  so_module (static)
#  http_module (static)
#  mpm_prefork_module (static)
#  authn_file_module (shared)
#  authn_core_module (shared)
#  authz_host_module (shared)
#  authz_groupfile_module (shared)
#  authz_user_module (shared)
#  authz_core_module (shared)
#  access_compat_module (shared)
#  auth_basic_module (shared)
#  socache_shmcb_module (shared)
#  reqtimeout_module (shared)
#  ext_filter_module (shared)
#  filter_module (shared)
#  deflate_module (shared)
#  mime_module (shared)
#  log_config_module (shared)
#  env_module (shared)
#  expires_module (shared)
#  headers_module (shared)
#  setenvif_module (shared)
#  version_module (shared)
#  remoteip_module (shared)
#  proxy_module (shared)
#  proxy_connect_module (shared)
#  proxy_ftp_module (shared)
#  proxy_http_module (shared)
#  proxy_fcgi_module (shared)
#  proxy_scgi_module (shared)
#  proxy_wstunnel_module (shared)
#  proxy_ajp_module (shared)
#  proxy_balancer_module (shared)
#  proxy_express_module (shared)
#  slotmem_shm_module (shared)
#  ssl_module (shared)
#  lbmethod_byrequests_module (shared)
#  lbmethod_bytraffic_module (shared)
#  lbmethod_bybusyness_module (shared)
#  lbmethod_heartbeat_module (shared)
#  unixd_module (shared)
#  status_module (shared)
#  autoindex_module (shared)
#  dir_module (shared)
#  alias_module (shared)
#  rewrite_module (shared
