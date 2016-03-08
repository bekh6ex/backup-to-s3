FROM cgswong/aws

RUN apk --no-cache add mysql-client

VOLUME /backup

