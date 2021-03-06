#!/usr/bin/env bash

DIR='/files'
BUCKET_ROOT='/backup'
MAX=30000

set -e

function s3sync {
    local FROM=$1
    local REMOTE_PATH=$2

    if [ ! -d "$FROM" ];
    then
        echo "Fail '${FROM}' - is not a directory"
        return 1
    fi

    set -x
    s3cmd sync --verbose --no-check-md5 --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} --delete-removed "${FROM}" "s3://${S3_BUCKET}${REMOTE_PATH}"
    set +x
}

function s3put {
    local FROM=$1
    local REMOTE_PATH=$2

    if [ ! -f "$FROM" ];
    then
        echo "Fail '${FROM}' - is not a file"
        return 1
    fi

    set -x
    s3cmd put --verbose --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} "${FROM}" "s3://${S3_BUCKET}${REMOTE_PATH}"
    set +x
}

function sync_dir {
    local DIR=$1

    if [ ! -d "$DIR" ];
    then
        echo "Fail '${DIR}' - is not a directory"
        return 1
    fi

    local COUNT=`find "$DIR" -type f | wc -l`

    if [ $COUNT -lt $MAX ];
    then
        do_sync "$DIR"
        return $?
    fi

    echo "Too many files in dir '${DIR}': ${COUNT} - splitting"

    local SAVEIFS=$IFS
    IFS=$(echo -en "\n\b") #Set up new array separator
    for D in `find "$DIR" -maxdepth 1 -type d`
    do
        if [[ "${D}" == "${DIR}" ]];
        then
          continue
        else
          sync_dir "$D"
        fi
    done

    for F in `find "$DIR" -maxdepth 1 -type f`
    do
        s3put "$F" "$(remote_path "$F")"
    done
    IFS=${SAVEIFS}

}

function do_sync {
    local DIR=$1

    if [ ! -d "$DIR" ];
    then
        echo "Fail '${DIR}' - is not a directory"
        return 1
    fi

    if [[ "${str:$i:1}" != '/' ]];
    then
        DIR="$DIR/"
    fi

    REMOTE_PATH=$(remote_path "${DIR}")

    s3sync ${DIR} ${REMOTE_PATH}
}

function remote_path {
    local PATH=$1

    echo "${PATH}" | /bin/sed -e "s#^${BUCKET_ROOT}##g"
}

#s3cmd sync --verbose --no-check-md5 --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} --delete-removed /backup/files/ s3://${S3_BUCKET}/files/

sync_dir "${BUCKET_ROOT}${DIR}"
