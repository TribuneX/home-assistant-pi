FROM multiarch/alpine:armhf-v3.8

LABEL Description="Home Assistant"

ARG TIMEZONE=Europe/Paris
ARG UID=1000
ARG GUID=1000
ARG MAKEFLAGS=-j4
ARG VERSION=0.85.1
ARG PLUGINS="sqlalchemy|HAP-python|PyXiaomiGateway|TravisPy|broadlink|colorlog|construct|distro|fastdotcom|fritzconnection|fritzhome|hole|home-assistant-frontend|influxdb|libnacl|luftdaten|miflora|netdisco|paho-mqtt|psutil|pyatv|pyfritzhome|pysonos|python-forecastio|python-miio|pytradfri[async]|pyuptimerobot|wakeonlan|aiohttp_cors|pyotp|PyQRCode"

ADD "https://raw.githubusercontent.com/home-assistant/home-assistant/${VERSION}/requirements_all.txt" /tmp

RUN apk add --no-cache git python3 ca-certificates libffi-dev libressl-dev nmap iputils glib-dev && \
    addgroup -g ${GUID} hass && \
    adduser -h /data -D -G hass -s /bin/sh -u ${UID} hass && \
    pip3 install --upgrade --no-cache-dir pip && \
    apk add --no-cache --virtual=build-dependencies build-base linux-headers python3-dev tzdata && \
    cp "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime && echo "${TIMEZONE}" > /etc/timezone && \
    sed '/^$/q' /tmp/requirements_all.txt > /tmp/requirements_core.txt && \
    sed '1,/^$/d' /tmp/requirements_all.txt > /requirements_plugins.txt && \
    egrep -e "${PLUGINS}" /requirements_plugins.txt | grep -v '#' > /tmp/requirements_plugins_filtered.txt && \
    pip3 install --no-cache-dir -r /tmp/requirements_core.txt && \
    pip3 install --no-cache-dir -r /tmp/requirements_plugins_filtered.txt && \
    pip3 install --no-cache-dir homeassistant=="${VERSION}" && \
    apk del build-dependencies && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 8123

ENTRYPOINT ["hass", "--open-ui", "--config=/data"]