#!/usr/bin/env bash

BACKUP_DIR=/backup/db
function make_backup {
    DB=$1
    DIR=${BACKUP_DIR}/${DB}
    rm -rf ${DIR} && mkdir -p -m 0777 ${DIR}
    for TABLE in `echo "SHOW TABLES" | mysql --login-path=backup -sN ${DB}`; do
        echo -n Dumping  ${DB}.${TABLE} ...
        mysqldump --user=${MYSQL_USER} --password=${MYSQL_PASS} --skip-comments ${DB} ${TABLE} > ${DIR}/${TABLE}.sql
        echo ' DONE'
    done

    for FILE in ${DIR}/*; do
        echo -n Gzipping file ${FILE} ...
        gzip -n -9 -q ${FILE}
        echo ' DONE'
    done

    s3cmd sync --delete-removed ${DIR} s3://${S3_BUCKET}/db/${DB}
}

make_backup ${MYSQL_DB}