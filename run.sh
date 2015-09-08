#!/bin/sh

# assume that if args begin with a "-", we want varnishd
# if it's varnish(stat|hist|top) etc, wait for a vsm file
case $1 in
	-*)
		# clear old varnish stuff
		rm -rf /var/lib/varnish/*
		ln -s /var/lib/varnish/`hostname` /var/lib/varnish/varnish
		exec /usr/sbin/varnishd $*
		;;
	varnishd | /usr/sbin/varnishd)
		exec $*
		;;
	varnish* | /usr/bin/varnish*)
	  	TRIES=0
		echo "waiting for varnish ($TRIES)"
	  	while [ ! -f /var/lib/varnish/varnish/_.vsm ]; do
			if [ $(expr $TRIES + 1) -eq 5 ]; then
				echo "Timed out waiting for a vsm file to appear"
				exec $*
			fi
			sleep 1
		done
		;;
esac
exec $*
