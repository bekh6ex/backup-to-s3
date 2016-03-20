#!/usr/bin/env bash

BACKUP_DIR=/backup/db
function make_backup {
    DB=$1
    DIR=${BACKUP_DIR}/${DB}
    rm -rf ${DIR} && mkdir -p -m 0777 ${DIR}
    for TABLE in `echo "SHOW TABLES" | mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASS} -sN ${DB}`; do
        echo -n Dumping  ${DB}.${TABLE} ...
        mysqldump --host=${MYSQL_HOST}  --user=${MYSQL_USER} --password=${MYSQL_PASS} --skip-comments ${DB} ${TABLE} > ${DIR}/${TABLE}.sql && \
        gzip -n -9 -q ${DIR}/${TABLE}.sql

        if [[ $? != 0 ]]
        then
          echo ' FAIL';
          exit 1;
        fi
        echo ' DONE'
    done

    s3cmd sync --verbose --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} ${DIR}/ s3://${S3_BUCKET}/db/${DB}/
}

make_backup ${MYSQL_DB}
