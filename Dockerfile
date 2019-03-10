FROM alpine:3.9
MAINTAINER lhie1<lhie1x@gmail.com>

ENV NODE_ID=0                     \
    ANTISSATTACK=0                \
    MU_SUFFIX=zhaoj.in            \
    MU_REGEX=%5m%id.%suffix       \
    API_INTERFACE=modwebapi       \
    WEBAPI_URL=https://zhaoj.in   \
    WEBAPI_TOKEN=glzjin           \
    MYSQL_HOST=127.0.0.1          \
    MYSQL_PORT=3306               \
    MYSQL_USER=ss                 \
    MYSQL_PASS=ss                 \
    MYSQL_DB=shadowsocks          \
    REDIRECT=github.com           \
    FAST_OPEN=true                \
    NS1=8.8.4.4                   \
    NS2=1.0.0.1

COPY . /root/shadowsocks
WORKDIR /root/shadowsocks

RUN apk update                               && \
    apk add --no-cache                          \
                        curl                    \
                        python3-dev             \
                        libsodium-dev           \
                        openssl-dev             \
                        udns-dev                \
                        mbedtls-dev             \
                        pcre-dev                \
                        libev-dev               \
                        libtool                 \
                        libffi-dev           && \
    apk add --no-cache --virtual .build-deps    \
                        tar                     \
                        make                    \
                        py3-pip                 \
                        autoconf                \
                        automake                \
                        build-base              \
                        linux-headers        && \
    ln -s /usr/bin/python3 /usr/bin/python   && \
    ln -s /usr/bin/pip3    /usr/bin/pip      && \
    pip install --upgrade pip                && \
    pip install -r requirements.txt          && \
    rm -rf ~/.cache && touch /etc/hosts.deny && \
    rm -rf /etc/localtime                    && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del --purge .build-deps

CMD cp apiconfig.py userapiconfig.py &&                                        cp   config.json  user-config.json && \
    sed -i "s|NODE_ID = 0|NODE_ID = ${NODE_ID}|"                               /root/shadowsocks/userapiconfig.py && \
    sed -i "s|ANTISSATTACK = 0|ANTISSATTACK = ${ANTISSATTACK}|"                /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MU_SUFFIX = 'zhaoj.in'|MU_SUFFIX = '${MU_SUFFIX}'|"              /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MU_REGEX = '%5m%id.%suffix'|MU_REGEX = '${MU_REGEX}'|"           /root/shadowsocks/userapiconfig.py && \
    sed -i "s|API_INTERFACE = 'modwebapi'|API_INTERFACE = '${API_INTERFACE}'|" /root/shadowsocks/userapiconfig.py && \
    sed -i "s|WEBAPI_URL = 'https://zhaoj.in'|WEBAPI_URL = '${WEBAPI_URL}'|"   /root/shadowsocks/userapiconfig.py && \
    sed -i "s|WEBAPI_TOKEN = 'glzjin'|WEBAPI_TOKEN = '${WEBAPI_TOKEN}'|"       /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MYSQL_HOST = '127.0.0.1'|MYSQL_HOST = '${MYSQL_HOST}'|"          /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MYSQL_PORT = 3306|MYSQL_PORT = ${MYSQL_PORT}|"                   /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MYSQL_USER = 'ss'|MYSQL_USER = '${MYSQL_USER}'|"                 /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MYSQL_PASS = 'ss'|MYSQL_PASS = '${MYSQL_PASS}'|"                 /root/shadowsocks/userapiconfig.py && \
    sed -i "s|MYSQL_DB = 'shadowsocks'|MYSQL_DB = '${MYSQL_DB}'|"              /root/shadowsocks/userapiconfig.py && \
    sed -i "s|\"redirect\": \"\"|\"redirect\": \"${REDIRECT}\"|"               /root/shadowsocks/user-config.json && \
    sed -i "s|\"fast_open\": true|\"fast_open\": ${FAST_OPEN}|"                /root/shadowsocks/user-config.json && \
    if [ $NS1 != 8.8.4.4 -a $NS2 = 1.0.0.1 ];then echo -e "$NS1 53">/root/shadowsocks/dns.conf ; else echo -e "$NS1 53\n$NS2 53">/root/shadowsocks/dns.conf ; fi && \
    python /root/shadowsocks/server.py