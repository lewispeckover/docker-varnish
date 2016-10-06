#!/bin/sh
set -e

CMDS="apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main varnish varnish-dev &&
      cd /vmods && rm -rf libvmod-dynamic && mkdir -p /vmods/install &&
      git clone -b 4.1 https://github.com/nigoroll/libvmod-dynamic.git && cd libvmod-dynamic &&
      PKG_CONFIG_PATH=/usr/lib/pkgconfig ./autogen.sh && ./configure && make &&
      echo '127.0.0.1 www.localhost img.localhost' >> /etc/hosts && make check && make install DESTDIR=/vmods/install"
docker run -it --rm -v `pwd`/vmods:/vmods lewispeckover/alpine-builder sh -c "$CMDS"
