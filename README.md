# Seafile docker image

Run mariadb or mysql image:

    docker run \
        --name mariadb-seafile \
        -v /$SOME_ABS_PATH/maria-seafile:/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=thisisabsolutlyinsecure \
        -e MYSQL_USER=seafile \
        -e MYSQL_PASSWORD=everybodyknowsthat \
        -d mariadb:latest

Run this image:

    docker run \
        --name seafile \
        -v /$SOME_ABS_PATH/seafile-data:/seafile-data/ \
        -p 80:8000 -p 8082:8082 -p 8080:8080 -p 10001:10001 -p 1201:1201 \
        --link mariadb-seafile:db \
        -e SITE_BASE=http://127.0.0.1 \
        -d seafile

Optionaly run nginx image.

## Enviroment variables:

- `MYSQL_HOST` - default: `db` comes from `--link some-mysql:db`
- `MYSQL_USER` - default comes from corresponding variable from linked machine
- `MYSQL_PASSWORD` - default comes from corresponding variable from linked machine
- `MYSQL_ROOT` - default comes from corresponding variable from linked machine, if it is not set no databases or roles will be created
- `MYSQL_ROOT_PASSWORD` - default comes from corresponding variable from linked machine
- `ADMIN_EMAIL` - Admin email (login) for all services (the default is `admin@example.com` - change it!)
- `ADMIN_PASSWORD` - Admin password (the default is `youcannotguesit` - change it!)
- `QUOTA` - default user quota in GB, integer only
- `KEEP_DAYS` - days to keep history
- `MAX_UPLOAD` - maximum upload file size
- `MAX_DOWNLOAD_DIR` - maximum download directory size
- `MEMCACHE_HOST` - enable memcache at this host for cache
- `MEMCACHE_PORT`
- `EMAIL_HOST` - default: `smtp.gmail.com`, SMPT server for email sending
- `EMAIL_PORT` - default: `587`
- `EMAIL_USE_TLS` - default: `True` - use TLS for SMPT
- `EMAIL_HOST_USER` - login to `EMAIL_HOST` with this user
- `EMAIL_HOST_PASSWORD` - enable email sending, use this password to login to `EMAIL_HOST`
- `CLOUD_MODE` - default: `False` - enable cloude mode and hide `Organization` tab
- `ENABLE_SIGNUP` - deafult: `False` - enable registration on web
- `TIME_ZONE` - default: `UTC`
- `SITE_BASE` - default: `http://www.example.com` - set this to seahub website's URL. This URL is contained in email notifications
- `SITE_NAME` - default: `example.com` - set this to your website's name. This is contained in email notifications
- `SITE_TITLE` - default: `Seafile` - set seahub website's title
- `SITE_ROOT` - default: `/` - if you don't want to run seahub website on your site's root path, set this option to your preferred path, e.g. setting it to `/seahub/` would run seahub on `http://example.com/seahub/`
- `SERVICE_BASE` - default: `SITE_BASE:8082`
- `SERVICE_URL` - default: `SITE_BASE:8082/`
- `ACTIVATE_AFTER_REGISTRATION` - default: `True` - activate user when registration complete. Default is `True`, if set to `False`, new users need to be activated by admin in admin panel.
- `WEBDAV_FASTCGI` - default: `false` - serve FastCGI for webdav on port 8080 for reverse proxy
- `USE_FASTCGI` - serve FastCGI for Seahub on port 8000 for reverse proxy
