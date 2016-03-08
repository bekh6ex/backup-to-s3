FROM cgswong/aws

RUN apk --no-cache add mysql-client

VOLUME /backup

COPY *.sh /

WORKDIR /

CMD ["/backup.sh"]

