FROM alpine:3.6

COPY ["nginx-unzip-module", "/tmp/nginx-unzip-module"]

RUN NGINX_VERSION=1.13.4 \
    && CONFIG="--prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_slice_module \
        --with-file-aio \
        --with-http_v2_module \
        --add-module=/tmp/nginx-unzip-module" \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && apk update \
    && apk add libressl pcre zlib libzip \
    && apk add --no-cache --virtual .build-deps \
        gcc libc-dev make libressl-dev pcre-dev zlib-dev libzip-dev linux-headers \
    && cd /tmp \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar xzf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd / \
    && apk del -r .build-deps \
    && rm -rf /tmp/* /var/cache/apk/* \
    \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ["nginx.conf", "/etc/nginx/nginx.conf"]

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]

