#!/usr/bin/env bash

red='\e[1;31m'
yellow='\e[1;33m'
green='\e[1;32m'
reset='\e[0m'     # Text reset

function ask_yn {
    local question="${1}";
    local result="$2"
    local myresult='';
    while [[ ${myresult} != "yes" && ${myresult} != "n" ]]
    do
        echo -n -e "${yellow}${question}${reset}(yes/n): "
#        echo_notice "${question}";
        read myresult;
    done
    if [[ $myresult == 'yes' ]]
    then
      return 0;
    else
      return 1;
    fi
}

if ask_yn "Do yoy want to restore data from backup?";
then
    s3cmd sync --no-check-md5 --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} s3://${S3_BUCKET}/ /backup/

    for DIR in /backup/db/*; do
      DB=${DIR##*/}
      echo "CREATE SCHEMA IF NOT EXISTS ${DB};" | mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASS}
      for FILE in ${DIR}/*.gz; do
        echo -n Restoring ${FILE} ...
        gzip -d -c ${FILE} | mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASS} ${DB}
        echo ' DONE'
      done
    done

    exit 0
else
    echo "Canceled!"
    exit 1
fi
