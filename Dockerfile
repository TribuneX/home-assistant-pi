FROM seblucas/alpine-homeassistant:latest

RUN apk add --no-cache --virtual=build-dependencies build-base linux-headers python3-dev shadow && \
    egrep -e "${PLUGINS}" /requirements_plugins.txt | grep -v '#' > /tmp/requirements_plugins_filtered.txt && \
    pip3 install --no-cache-dir -r /requirements_plugins.txt && \
    apk del build-dependencies && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 8123

ENTRYPOINT ["hass", "--open-ui", "--config=/data"]