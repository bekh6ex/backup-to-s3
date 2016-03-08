#!/usr/bin/env bash

s3cmd sync --no-check-md5 --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} s3://${S3_BUCKET}/ /backup

for DIR in /backup/db/*; do
  DB=${DIR##*/}
  for FILE in ${DIR}; do
    echo -n Restoring ${FILE} ...
    gzip -d -c ${FILE} | mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASS} ${DB}
    echo ' DONE'
  done
done


