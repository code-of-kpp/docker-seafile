FROM ubuntu:latest

ENV \
    SEAFILE_VERSION=6.0.4_x86-64 \
    ADMIN_EMAIL=admin@example.com \
    ADMIN_PASSWORD=youcannotguessit \
    SITE_NAME=seafile \
    SITE_BASE=http://127.0.0.1 \
    SITE_ROOT=/

EXPOSE 12001 10001 8000 8080 8082

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    export DOWNLOAD_ROOT=https://bintray.com/artifact/download/seafile-org/seafile && \
    apt-get update && dpkg --clear-selections && apt-get autoremove -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
        wget "libmariadb-?client.*-dev" openssl sqlite3 python2.7 \
        python-urllib3 python-imaging python-mysqldb python-memcache && \
    export URL=`wget -q -O- https://www.seafile.com/en/download/ | \
                grep -E 'server.*x86-64.tar.gz' | head -n 1 | \
                grep --only-matching -E 'http[^\"]+' || \
                echo $DOWNLOAD_ROOT/seafile-server_${SEAFILE_VERSION}.tar.gz` && \
    mkdir -p /usr/local/seafile/ && mkdir -p /etc/seafile/ && mkdir -p /seafile-data/ && \
    mkdir -p /run/seafile/ && ln -sT /run/seafile /usr/local/seafile/pids && \
    mkdir -p /var/log/seafile/ && ln -sT /var/log/seafile /usr/local/seafile/logs && \
    ln -sT /seafile-data/ /usr/local/seafile/seafile-data && \
    ln -sT /seafile-data/ /usr/local/seafile/seahub-data && \
    cd /usr/local/seafile && \
    wget -q -O- $URL | tar -xz && \
    mv seafile-server* seafile-server && cd seafile-server && \
    ln -s setup-seafile-mysql.py ssm.py && ln -s setup-seafile.py ssq.py && \
    ln -s /usr/local/seafile/conf/seafdav.conf /etc/seafile/ && \
    ln -s /usr/local/seafile/conf/ccnet.conf /etc/seafile/ccnet.conf && \
    ln -s /usr/local/seafile/conf/seafile.conf /etc/seafile/seafile.conf && \
    ln -s /usr/local/seafile/conf/seahub_settings.py /etc/seafile/seahub_settings.py && \
    SUDO_FORCE_REMOVE=yes apt-get purge -y wget binutils perl manpages-dev ucf sudo && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /var/log/*/*

ADD *.sh /usr/local/bin/
ADD *.py /usr/local/seafile/seafile-server/

VOLUME /seafile-data

CMD \
    sh /usr/local/bin/warmup.sh && \
    . /usr/local/bin/clean_env.sh && \
    for file in /var/log/seafile/*; do tailf $file & done && \
    tail -F /usr/local/seafile/seafile-server/runtime/access.log & \
    tail -F /usr/local/seafile/seafile-server/runtime/error.log
