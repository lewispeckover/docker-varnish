#!/bin/sh

docker run -it --rm -v `pwd`/build:/build --entrypoint /build/entrypoint.sh lewispeckover/apkbuilder
