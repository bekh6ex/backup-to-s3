#!/usr/bin/env bash

s3cmd sync --dry-run --no-check-md5 --access_key=${S3_ACCESS_KEY} --secret_key=${S3_SECRET_KEY} --delete-removed /backup/files s3://${S3_BUCKET}/files