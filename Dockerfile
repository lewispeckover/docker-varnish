FROM lewispeckover/base:3.5
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
RUN	apk add --no-cache gcc libc-dev libgcc && \
	addgroup -S varnish && adduser -S -D -H -h /var/lib/varnish -s /sbin/nologin -G varnish -g varnish varnish && \
	install -d -o varnish -g varnish -m750 /var/cache/varnish /var/log/varnish /var/lib/varnish && \
	install -d -o root -g varnish -m750 /etc/varnish 
COPY ./varnish/dist /
COPY ./conf /etc/varnish
