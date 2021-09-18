#!/usr/bin/env bash

set -e;

NGINX_VER=1.21.1
NAXSI_VER=1.3
NPS_VERSION=1.13.35.2-stable

mkdir ~/nginx

# update
apt-get update

# Nginx
apt-get install -y libgd-dev libpcre3 libpcre3-dev libssl-dev zlib1g-dev
cd ~/nginx
wget https://nginx.org/download/nginx-$NGINX_VER.tar.gz
tar vxf nginx-$NGINX_VER.tar.gz; rm -rf nginx-$NGINX_VER.tar.gz

# mruby
cd ~/nginx
git clone https://github.com/matsumotory/ngx_mruby.git
cd ~/nginx/ngx_mruby
./configure --with-ngx-src-root=../nginx-$NGINX_VER --with-ngx-config-opt=--prefix=/etc/nginx
make build_mruby
make generate_gems_config

# NAXSI
cd ~/nginx
wget https://github.com/nbs-system/naxsi/archive/$NAXSI_VER.tar.gz -O naxsi_$NAXSI_VER.tar.gz
tar vxf naxsi_$NAXSI_VER.tar.gz; rm -rf naxsi_$NAXSI_VER.tar.gz

# Pagespeed
cd ~/nginx
apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip uuid-dev
wget -O- https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.tar.gz | tar -xz
nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
cd "$nps_dir"
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget -O- ${psol_url} | tar -xz  # extracts to psol/

# headers-more-nginx-module
cd ~/nginx
git clone https://github.com/openresty/headers-more-nginx-module.git

# brotli
cd ~/nginx
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli
git submodule update --init

# Configure
cd ~/nginx/nginx-$NGINX_VER
./configure \
--add-module=../ngx_mruby \
--add-module=../ngx_mruby/dependence/ngx_devel_kit \
--add-dynamic-module=../naxsi-$NAXSI_VER/naxsi_src/ \
--add-dynamic-module=../ngx_brotli/ \
--add-module=../headers-more-nginx-module \
--add-module=../incubator-pagespeed-ngx-1.13.35.2-stable \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib64/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_v2_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' \
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' \
--with-http_image_filter_module \
--with-pcre \
--with-pcre-jit

# Install
make modules; make; make install
mkdir /etc/nginx/modules/
cp ~/nginx/nginx-$NGINX_VER/objs/ngx_http_naxsi_module.so /etc/nginx/modules/
cp ~/nginx/nginx-$NGINX_VER/objs/ngx_http_brotli_filter_module.so /etc/nginx/modules/
cp ~/nginx/nginx-$NGINX_VER/objs/ngx_http_brotli_static_module.so /etc/nginx/modules/
cp ~/nginx/naxsi-$NAXSI_VER/naxsi_config/naxsi_core.rules /etc/nginx/naxsi_rules
mkdir -p /var/cache/nginx/cache
rm -rf ~/nginx
