#!/bin/dumb-init /bin/sh
set -e
VARNISH_VERSION=4.1.5

# install build deps
apk add --no-cache pcre-dev ncurses-dev libedit-dev py-docutils linux-headers gcc libc-dev libgcc


# fetch & extract
mkdir -p /build/src /build/dist
chown -R builder /build
cd /build/src
su-exec builder curl -fLO# https://repo.varnish-cache.org/source/varnish-${VARNISH_VERSION}.tar.gz
su-exec builder tar xzf varnish-${VARNISH_VERSION}.tar.gz
cd varnish-${VARNISH_VERSION}

# apply patches
for p in ../../patches/*.patch; do
        su-exec builder patch -p1 < $p
done

# borrow envs from abuild
CXXFLAGS="-Os -fomit-frame-pointer -g" 
JOBS="2" 
LDFLAGS="-Wl,--as-needed" 
MAKEFLAGS="-j2" 
REPODEST="/build/packages/" 
CFLAGS="-Os -fomit-frame-pointer -g" 
CPPFLAGS="-Os -fomit-frame-pointer" CC="gcc" 

# build it
su-exec builder ./configure --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --infodir=/usr/share/info --localstatedir=/var/lib --without-jemalloc
su-exec builder make
su-exec builder make check

# install
su-exec builder make DESTDIR="/build/dist" install
#install -d -o varnish -g varnish -m750 \
#       "$pkgdir"/var/cache/varnish \
#       "$pkgdir"/var/log/varnish \
#       "$pkgdir"/var/lib/varnish 
#install -d -o root -g varnish -m750 "$pkgdir"/etc/varnish || return 1

