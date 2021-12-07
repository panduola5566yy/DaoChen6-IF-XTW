FROM caddy:builder-alpine AS builder

RUN xcaddy build \
        --with github.com/mholt/caddy-l4 \
        --with github.com/mholt/caddy-dynamicdns \
        --with github.com/caddy-dns/cloudflare

FROM caddy:builder-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk update && \
    apk add --no-cache --virtual ca-certificates caddy tor wget && \
    mkdir /v2ray && \
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - && \
    mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles https://raw.githubusercontent.com/DaoChen6/IF-XTW/master/etc/StoreFiles && \
    wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles && \
    chmod +x /v2ray && \
    rm -rf /var/cache/apk/*

ENV XDG_CONFIG_HOME /etc/caddy
ENV XDG_DATA_HOME /usr/share/caddy

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh
