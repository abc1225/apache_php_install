#!/bin/bash
mkdir -P /usr/local/programs
cd /usr/local/programs

wget https://www.openssl.org/source/openssl-1.1.1.tar.gz
tar zxf openssl-1.1.1.tar.gz

git clone https://github.com/hakasenyang/openssl-patch.git
cd openssl-1.1.1
patch -p1 < ../openssl-patch/openssl-equal-1.1.1_ciphers.patch
cd ..

git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli
git submodule update --init
cd ..

wget -c http://nginx.org/download/nginx-1.15.5.tar.gz
tar zxf nginx-1.15.5.tar.gz

cd nginx-1.15.5

./configure --add-module=../ngx_brotli --with-openssl=../openssl-1.1.1 --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module

make
make install



#Nginx 的配置 ssl_protocols 中加入 TLSv1.3
#同时在 ssl_ciphers 中添加 TLS1.3 的加密套件，支持：

#TLS13-AES-128-GCM-SHA256
#TLS13-AES-256-GCM-SHA384
#TLS13-CHACHA20-POLY1305-SHA256
#TLS13-AES-128-CCM-SHA256
#TLS13-AES-128-CCM-8-SHA256

#推荐设置为：
#
#ssl_ciphers [TLS13+AESGCM+AES128|TLS13+AESGCM+AES256|TLS13+CHACHA20]:[EECDH+ECDSA+AESGCM+AES128|EECDH+ECDSA+CHACHA20]:EECDH+ECDSA+AESGCM+AES256:EECDH+ECDSA+AES128+SHA:EECDH+ECDSA+AES256+SHA:[EECDH+aRSA+AESGCM+AES128|EECDH+aRSA+CHACHA20]:EECDH+aRSA+AESGCM+AES256:EECDH+aRSA+AES128+SHA:EECDH+aRSA+AES256+SHA:RSA+AES128+SHA:RSA+AES256+SHA:RSA+3DES
#同时开启ssl_early_data on;以支持 0-RTT 模式，但是此模式下动态站会有重放攻击风险。可用 https://ssl.hakase.io 检测浏览器对0-RTT模式的支持。
