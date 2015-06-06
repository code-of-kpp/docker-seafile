FROM ubuntu:latest

ENV \
    SEAFILE_VERSION=4.2.2_x86-64 \
    ADMIN_EMAIL=admin@example.com \
    ADMIN_PASSWORD=youcannotguessit \
    SITE_NAME=seafile \
    SITE_BASE=http://seafile.example.com \
    SITE_ROOT=/

EXPOSE 1201 10001 8000 8080 8082

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && dpkg --clear-selections && apt-get autoremove -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget "libmariadb-?client.*-dev" openssl && \
    apt-get install -y python2.7 python-pkg-resources python-flup python-imaging python-mysqldb python-memcache && \
    mkdir -p /usr/local/seafile/ && \
    mkdir -p /run/seafile/ && ln -sT /run/seafile /usr/local/seafile/pids && \
    mkdir -p /var/log/seafile/ && ln -sT /var/log/seafile /usr/local/seafile/logs && \
    mkdir -p /seafile-data/ && ln -sT /seafile-data/ /usr/local/seafile/seafile-data && \
    cd /usr/local/seafile && \
    wget -O- https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_${SEAFILE_VERSION}.tar.gz | tar -xz && \
    mv seafile-server* seafile-server && \
    SUDO_FORCE_REMOVE=yes apt-get purge -y wget binutils perl libpython3.4-stdlib manpages-dev ucf sudo && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD *.sh /usr/local/bin/
ADD *.py /usr/local/bin/

VOLUME /seafile-data

CMD \
    sh /usr/local/bin/warmup.sh && \
    . /usr/local/bin/clean_env.sh && \
    for file in /var/log/seafile/*; do tailf $file & done && \
    tail -F /usr/local/seafile/seafile-server/runtime/access.log & \
    tail -F /usr/local/seafile/seafile-server/runtime/error.log
