FROM alpine:latest
RUN apk --update upgrade && apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main varnish
COPY run.sh /
ENTRYPOINT ["/run.sh"]
