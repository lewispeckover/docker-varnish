#!/bin/dumb-init /bin/bash
set -e
VARNISH_VERSION=4.1.5
MODULES=( https://github.com/nigoroll/libvmod-dynamic#master https://github.com/carlosabalde/libvmod-redis#4.1 )

# install build deps
apk add --no-cache	autoconf automake libtool m4 \
			pcre-dev ncurses-dev libedit-dev py-docutils linux-headers gcc libc-dev libgcc hiredis-dev libev-dev python


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

# install to /dist
su-exec builder make DESTDIR="/build/dist" install
# and also install properly so we can build modules
make install

# modules..
for MODULE in ${MODULES[@]}; do 
	cd /build/src
	TAG=$(echo $MODULE | cut -d '#' -f2)
	MODULE=$(echo $MODULE | cut -d '#' -f1)
	M=$(basename $MODULE)
	[ -d $M/.git ] || git clone $MODULE
	cd $M
	git fetch && git checkout $TAG && git pull && chown -R builder .
	[ -x ./autogen.sh ] && su-exec builder ./autogen.sh
	[ -x ./configure ] && su-exec builder ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --infodir=/usr/share/info --localstatedir=/var/lib
       	su-exec builder make
	su-exec builder make DESTDIR="/build/dist" install
done
