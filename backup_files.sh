#!/usr/bin/env bash

s3cmd sync --no-check-md5 --delete-removed /backup/files s3://${S3_BUCKET}/files