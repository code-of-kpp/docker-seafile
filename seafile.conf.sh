#!/bin/bash

mkdir -p /etc/seafile

ln -s /usr/local/seafile/ccnet/ccnet.conf /etc/seafile/ccnet.conf
ln -s /usr/local/seafile/seafile-data/seafile.conf /etc/seafile/seafile.conf

cat >> /usr/local/seafile/seafile-data/seafile.conf <<EOF
[quota]
# default user quota in GB, integer only
default = ${QUOTA:-2}

[history]
keep_days = $KEEP_DAYS

[fileserver]
# tcp port for fileserver
port = 8082

# Set maximum upload file size to 200M.
max_upload_size=$MAX_UPLOAD

# Set maximum download directory size to 200M.
max_download_dir_size=$MAX_DOWNLOAD_DIR
EOF
