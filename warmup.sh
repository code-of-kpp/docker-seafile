#!/bin/sh

export ROOT=/usr/local/seafile/seafile-server
export PYTHONPATH=$ROOT/seafile/lib/python2.6/site-packages:$ROOT/seafile/lib64/python2.6/site-packages:$ROOT/seahub/thirdpart:$PYTHONPATH
export PYTHONPATH=$ROOT/seafile/lib/python2.7/site-packages:$ROOT/seafile/lib64/python2.7/site-packages:$PYTHONPATH
export CCNET_CONF_DIR=/usr/local/seafile/ccnet/

mkdir -p /seafile-data/library-template || :

cd $ROOT
python -m makedb

rm $ROOT/makedb.py
rm $ROOT/ssm.py
rm $ROOT/ssq.py

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
enabled = true
host= 0.0.0.0
port = 8080
fastcgi = ${WEBDAV_FASTCGI:-false}
share_name = ${WEBDAV_SHARE_NAME:-/}
EOF

sed -i "s@SERVICE_URL = http://127.0.0.1:8000@SERVICE_URL = ${SERVICE_BASE:-$SITE_BASE/}@" \
    /usr/local/seafile/ccnet/ccnet.conf

true | /usr/local/seafile/seafile-server/upgrade/minor-upgrade.sh

cat > prepare_.py <<EOF
import os

import check_init_admin

if check_init_admin.need_create_admin():
   check_init_admin.create_admin(${ADMIN_EMAIL:-admin@example.com}),
                                 ${ADMIN_PASSWORD:-youcannotguessit})
)
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
