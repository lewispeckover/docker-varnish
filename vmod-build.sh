#!/bin/sh
set -e

CMDS="apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main varnish varnish-dev;
      cd /vmods && rm -rf libvmod-dynamic;
      git clone -b 4.1 https://github.com/nigoroll/libvmod-dynamic.git && cd libvmod-dynamic;
      PKG_CONFIG_PATH=/usr/lib/pkgconfig ./autogen.sh && ./configure && make;
      echo '127.0.0.1 www.localhost img.localhost' >> /etc/hosts && make check"
docker run -it --rm -v vmods:/vmods lewispeckover/alpine-builder sh -c "$CMDS"
