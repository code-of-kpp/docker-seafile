# Seafile docker image

## Run manually

First, you need to run mariadb or mysql image:

```shell
docker run \
    --name seafile-mariadb \
    -v /$SOME_ABS_PATH/maria-seafile:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=thisisabsolutlyinsecure \
    -e MYSQL_USER=seafile \
    -e MYSQL_PASSWORD=everybodyknowsthat \
    -d mariadb:latest
```

### Run this image

```shell
docker run \
   --name seafile \
   -v /$SOME_ABS_PATH/seafile-data:/seafile-data/ \
   -p 80:8000 -p 8082:8082 -p 8080:8080 -p 10001:10001 -p 12001:12001 \
   --link seafile-mariadb:db \
   -e SITE_BASE=http://127.0.0.1 \
   -d podshumok/seafile
```

### Run with nginx

1. Run this image with `-e SEAFILE_FASTCGI_HOST=0.0.0.0`:

    ```shell
    docker run \
        --name seafile \
        -v /$SOME_ABS_PATH/seafile-data:/seafile-data/ \
        -p 10001:10001 -p 12001:12001 \
        --link seafile-mariadb:db \
        -e SITE_BASE=http://127.0.0.1 \
        -e SEAFILE_FASTCGI_HOST=0.0.0.0 \
        -d podshumok/seafile
    ```

2. Create `/$SOME_ABS_PATH/conf.d/default.conf` (nginx configuration file):

    ```shell
    mkdir -p /$SOME_ABS_PATH/conf.d
    wget https://github.com/podshumok/docker-seafile/raw/master/conf.d/default.conf \
        -O /$SOME_ABS_PATH/conf.d/default.conf
    ```

3. Run nginx image:

    ```shell
    docker run \
        --name seafile-nginx \
        -p 80:80 \
        --link seafile:seafile \
        -v /$SOME_ABS_PATH/conf.d:/etc/nginx/conf.d \
        -v /$SOME_ABS_PATH/nginxlog:/var/log/nginx \
        -v /$SOME_EMPTY_DIR:/etc/nginx/sites-enabled \
        -v /$SOME_EMPTY_DIR:/etc/nginx/certs \
        -v /$SOME_EMPTY_DIR:/var/www/html \
        -d nginx
    ```

## Run seafile with docker-compose

Create project tree:

    seafile/
    |--- conf.d/
    |----|--- default.conf  # nginx configuration file
    |----ssl/               # (optional)
    |----|--- seafile.crt   # your cacert.pem
    |----|--- seafile.key   # your privkey.pem
    |--- data/
    |--- docker-compose.yml

Template  for `conf.d/default.conf` is [here](https://github.com/podshumok/docker-seafile/blob/master/conf.d/default.conf).
If you need HTTPS replace `listen 80;` with `listen 443 ssl;` and add `ssl_certificate` and `ssl_certificate_key` e.g.:

```nginx
server {
    listen 443 ssl;
    ssl_certificate         certs/seafile.crt;
    ssl_certificate_key     certs/seafile.key;
    ...
```

`docker-compose.yml` sketch:

```yaml
mariadb:
  image: mariadb:latest
  volumes:
    - ./data/maria:/var/lib/mysql
    - ./data/log/maria:/var/log/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=pleasechangeitorelse
    - MYSQL_USER=seafile
    - MYSQL_PASSWORD=thisoneshouldbechangedtoo

main:
  image: podshumok/seafile
  volumes:
    - ./data/seafile:/seafile-data/
    - ./data/log/seafile:/var/log/seafile
  links:
    - mariadb:db
  environment:
    # replace http:// with https:// for SSL configuration
    - SITE_BASE=http://127.0.0.1
    - SEAFILE_FASTCGI_HOST=0.0.0.0

nginx:
  image: nginx
  ports:
    - "443:443"
  links:
    - seafile
  volumes:
    - ./conf.d:/etc/nginx/conf.d:ro
    - ./ssl:/etc/nginx/certs:ro
    - ./data/log/nginx:/var/log/nginx
    - /tmp/empty:/etc/nginx/sites-enabled:ro
    - /tmp/empty:/var/www/html:ro
```

Now just run `docker-compose up` in the project root.


## Environment variables

- `MYSQL_HOST` - default: `db` comes from `--link some-mysql:db`
- `MYSQL_USER` - default comes from corresponding variable from linked machine
- `MYSQL_PASSWORD` - default comes from corresponding variable from linked machine
- `MYSQL_ROOT` - default comes from corresponding variable from linked machine, if it is not set no databases or roles will be created
- `MYSQL_ROOT_PASSWORD` - default comes from corresponding variable from linked machine
- `ADMIN_EMAIL` - Admin email (login) for all services (the default is `admin@example.com` - change it!)
- `ADMIN_PASSWORD` - Admin password (the default is `youcannotguessit` - change it!)
- `QUOTA` - default: `2` - user quota in GB, integer only
- `KEEP_DAYS` - days to keep history
- `MAX_UPLOAD` - maximum upload file size
- `MAX_DOWNLOAD_DIR` - maximum download directory size
- `MEMCACHE_HOST` - enable memcache at this host for cache (just `--link some-memcached:memcache`)
- `MEMCACHE_PORT` - default: `11211`
- `EMAIL_HOST` - default: `smtp.gmail.com`, SMPT server for email sending
- `EMAIL_PORT` - default: `587`
- `EMAIL_USE_TLS` - default: `True` - use TLS for SMPT
- `EMAIL_HOST_USER` - login to `$EMAIL_HOST` with this user
- `EMAIL_HOST_PASSWORD` - enable email sending, use this password to login to `$EMAIL_HOST`
- `CLOUD_MODE` - default: `False` - enable cloud mode and hide `Organization` tab
- `ENABLE_SIGNUP` - deafult: `False` - enable registration on web
- `TIME_ZONE` - default: `UTC`
- `SITE_BASE` - default: `http://www.example.com` - set this to seahub website's URL. This URL is contained in email notifications
- `SITE_NAME` - default: `example.com` - set this to your website's name. This is contained in email notifications
- `SITE_TITLE` - default: `Seafile` - set seahub website's title
- `SITE_ROOT` - default: `/` - if you don't want to run seahub website on your site's root path, set this option to your preferred path, e.g. setting it to `/seahub/` would run seahub on `http://example.com/seahub/`
- `SERVICE_BASE` - default: `$SITE_BASE`
- `SERVICE_URL` - default: `$SITE_BASE/` if `$SEAFILE_FASTCGI_HOST` is not set, `$SITE_BASE/seafhttp` otherwise
- `ACTIVATE_AFTER_REGISTRATION` - default: `True` - activate user when registration complete. Default is `True`, if set to `False`, new users need to be activated by admin in admin panel.
- `SEAFILE_FASTCGI_HOST` - default: not set - serve FastCGI for Seahub on `$SEAFILE_FASTCGI_HOST:8000` for reverse proxy
- `WEBDAV_FASTCGI` - default: `false` if `$SEAFILE_FASTCGI_HOST` is not set, `true` otherwise - serve FastCGI for webdav on port `8080` for reverse proxy
- `WEBDAV_SHARE_NAME` - default: `/` if `$WEBDAV_FASTCGI` equals `false` or is not set, `/seafdav` otherwise
