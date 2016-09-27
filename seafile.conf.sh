#!/bin/bash

cat >> /usr/local/seafile/conf/seafile.conf <<EOF
[quota]
# default user quota in GB, integer only
default = ${QUOTA:-2}

[history]
keep_days = $KEEP_DAYS

[fileserver]
# Set maximum upload file size to 200M.
max_upload_size=$MAX_UPLOAD

# Set maximum download directory size to 200M.
max_download_dir_size=$MAX_DOWNLOAD_DIR
EOF
