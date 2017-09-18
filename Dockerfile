FROM alpine:latest

# ADD AND RUN
RUN sed -i 's/v3.2/edge/g' /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add --no-cache --update nodejs nodejs-npm \
        && apk del nodejs-doc nodejs-dev \
        && npm cache clean && rm -rf /tmp/* /var/cache/apk/*

# COMMAND and ENTRYPOINT:
CMD ["/bin/sh"]

