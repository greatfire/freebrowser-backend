FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV FBNGINX_PATH=/opt/fbnginx

RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    gcc \
    wget \
    logrotate \
    dnsmasq \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
  wget http://nginx.org/download/nginx-1.24.0.tar.gz \
  && tar zxvf nginx-1.24.0.tar.gz

RUN cd /tmp && \
  wget https://github.com/openresty/headers-more-nginx-module/archive/v0.35.tar.gz \
  -O headers-more-nginx-module-v0.35.tar.gz \
  && tar zxvf headers-more-nginx-module-v0.35.tar.gz
RUN cd /tmp && \
  wget https://github.com/openresty/echo-nginx-module/archive/v0.63.tar.gz \
  -O echo-nginx-module-v0.63.tar.gz \
  && tar zxvf echo-nginx-module-v0.63.tar.gz


RUN cd /tmp && \
  wget https://www.openssl.org/source/openssl-1.0.2u.tar.gz \
  && tar zxvf openssl-1.0.2u.tar.gz

RUN cd /tmp/nginx-1.24.0 \
  && ./configure \
  --prefix=$FBNGINX_PATH \
  --add-module=../headers-more-nginx-module-0.35 \
  --add-module=../echo-nginx-module-0.63 \
  --with-http_ssl_module \
  --with-openssl=../openssl-1.0.2u \
  --with-cc-opt='-O2 -Wno-implicit-fallthrough' \
  && make \
  && make install

RUN rm -rf /tmp/*

ENV PATH="$FBNGINX_PATH/sbin:$PATH"


COPY ./conf $FBNGINX_PATH/conf


RUN cd $FBNGINX_PATH/conf && \
  wget https://curl.se/ca/cacert.pem


RUN chmod +x $FBNGINX_PATH/conf/start.sh

RUN chmod 0600 $FBNGINX_PATH/conf/logrotate
RUN (crontab -l 2>/dev/null; echo "0 0 * * * /usr/sbin/logrotate $FBNGINX_PATH/conf/logrotate"; \
  echo "0 12 * * * /usr/sbin/logrotate $FBNGINX_PATH/conf/logrotate") | crontab -


VOLUME ["$FBNGINX_PATH/logs"] 

EXPOSE 5353 5353/udp
EXPOSE 80 443

CMD ["/bin/sh", "-c", "$FBNGINX_PATH/conf/start.sh"]
