FROM alpine
RUN apk add --update varnish
COPY run.sh /
ENTRYPOINT ["/run.sh"]
