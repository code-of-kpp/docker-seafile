#!/bin/sh

export ROOT=/usr/local/seafile/seafile-server
export PYTHONPATH=$ROOT/seafile/lib/python2.6/site-packages:$ROOT/seafile/lib64/python2.6/site-packages:$ROOT/seahub/thirdpart:$PYTHONPATH
export PYTHONPATH=$ROOT/seafile/lib/python2.7/site-packages:$ROOT/seafile/lib64/python2.7/site-packages:$PYTHONPATH
export CCNET_CONF_DIR=/usr/local/seafile/ccnet/

mkdir -p /usr/local/seafile/seafile-data/library-template || :

ln -s $ROOT/setup-seafile-mysql.py $ROOT/ssm.py
cd $ROOT
ln -s /usr/local/bin/makedb.py $ROOT

python -m makedb
rm $ROOT/makedb.py

bash /usr/local/bin/seafile.conf.sh
bash /usr/local/bin/seahub_settings.py.sh

ln -s /usr/local/seafile/conf/seafdav.conf /etc/seafile/

cat > /usr/local/seafile/conf/seafdav.conf <<EOF
[WEBDAV]
enabled = true
port = 8080
fastcgi = ${WEBDAV_FASTCGI:-false}
share_name = /
EOF

sed -i "s@SERVICE_URL = http://127.0.0.1:8000@SERVICE_URL = ${SERVICE_BASE:-$SITE_BASE/}@" \
    /usr/local/seafile/ccnet/ccnet.conf

true | /usr/local/seafile/seafile-server/upgrade/minor-upgrade.sh

export _create_="
import os

import check_init_admin

if check_init_admin.need_create_admin():
   check_init_admin.create_admin(os.environ.get('ADMIN_EMAIL', 'admin@example.com'),
                                 os.environ.get('ADMIN_PASSWORD', 'youcannotguessit')
)
"
. /usr/local/bin/clean_env.sh

./seafile.sh start
python -c "$_create_"
unset _create_

if [ -n "$USE_FASTCGI" ]; then
   ./seahub.sh start-fastcgi
else
   ./seahub.sh start
fi

./seaf-fsck.sh  -r -e
