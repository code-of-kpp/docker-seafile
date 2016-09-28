#!/bin/sh

export ROOT=/usr/local/seafile/seafile-server
export PYTHONPATH=$ROOT/:$ROOT/seahub:$ROOT/seahub/thirdpart:${ROOT}/seafile/lib64/python2.6/site-packages/:$PYTHONPATH
export CCNET_CONF_DIR=/usr/local/seafile/conf
export LD_LIBRARY_PATH=${ROOT}/seafile/lib/:${ROOT}/seafile/lib64:${LD_LIBRARY_PATH}
export PATH=${ROOT}/seafile/bin:${PATH}

mkdir -p /seafile-data/library-template || :
mkdir -p ${CCNET_CONF_DIR}

cd $ROOT
python -m makedb

rm $ROOT/makedb.py
#rm $ROOT/ssm.py
#rm $ROOT/ssq.py

bash /usr/local/bin/seafile.conf.sh
bash /usr/local/bin/seahub_settings.py.sh

if [ -n "$SEAFILE_FASTCGI_HOST" ]; then
    export WEBDAV_FASTCGI=true
    if [ -z "$SERVICE_BASE" ]; then
        export SERVICE_BASE=$SITE_BASE/seafhttp
    fi
fi

if [ -n "$WEBDAV_FASTCGI" -a "$WEBDAV_FASTCGI" != "false" ]; then
    if [ -z "$WEBDAV_SHARE_NAME" ]; then
        export WEBDAV_SHARE_NAME=/seafdav
    fi
fi

cat > /usr/local/seafile/conf/seafdav.conf <<EOF
[WEBDAV]
enabled = ${WEBDAV_ENABLED:-true}
host= 0.0.0.0
port = 8080
fastcgi = ${WEBDAV_FASTCGI:-false}
share_name = ${WEBDAV_SHARE_NAME:-/}
EOF

ccnet-init \
    -c /usr/local/seafile/ccnet/ \
    -F /usr/local/seafile/conf/ \
    --name ${SITE_NAME} \
    --host ${SITE_NAME} || echo 'using existing ccnet configuration'

ccnet_id=$(grep ID /usr/local/seafile/conf/ccnet.conf | cut -f 3 -d ' ')
ccnet_user=$(grep USER /usr/local/seafile/conf/ccnet.conf | cut -f 3 -d ' ')
ccnet_url=$(grep SERVICE_URL /usr/local/seafile/conf/ccnet.conf | cut -f 3 -d ' ')

cat > ${CCNET_CONF_DIR}/ccnet.conf <<EOF
[General]
USER_NAME = ${CCNET_USER:-${ccnet_user}}
ID = ${CCNET_ID:-${ccnet_id}}
NAME = ${CCNET_NAME:-${SITE_NAME}}
SERVICE_URL = ${CCNET_URL:-${ccnet_url}}

[Client]
PORT = 13419
EOF

seaf-server-init \
    --central-config-dir /usr/local/seafile/conf/ \
    --seafile-dir /seafile-data/

true | /usr/local/seafile/seafile-server/upgrade/minor-upgrade.sh

cat > prepare_.py <<EOF
import os

import check_init_admin

if check_init_admin.need_create_admin():
   check_init_admin.create_admin('${ADMIN_EMAIL:-admin@example.com}',
                                 '${ADMIN_PASSWORD:-youcannotguessit}')
EOF
. /usr/local/bin/clean_env.sh

./seafile.sh start
python -m prepare_
rm prepare_.py

if [ -n "$SEAFILE_FASTCGI_HOST" ]; then
   ./seahub.sh start-fastcgi
else
   ./seahub.sh start
fi

./seaf-fsck.sh  -r -e
