#!/bin/bash

export CONF=/usr/local/seafile/seahub_settings.py

if [ -n "$MEMCACHE_HOST" ]; then
cat >> $CONF << EOF

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': "$MEMCACHE_HOST:${MEMCACHE_PORT:-11211}",
    }
}

EOF
fi

if [ -n "$EMAIL_HOST_PASSWORD" ]; then
cat >> $CONF << EOF

EMAIL_USE_TLS = ${EMAIL_USE_TLS:-True}
EMAIL_HOST = "${EMAIL_HOST:-smtp.gmail.com}"
EMAIL_HOST_USER = "$EMAIL_HOST_USER"
EMAIL_HOST_PASSWORD = "$EMAIL_HOST_PASSWORD"
EMAIL_PORT = ${EMAIL_PORT:-587}
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
SERVER_EMAIL = EMAIL_HOST_USER

EOF
fi

if [ -n "$SEAFILE_FASTCGI_HOST" ]; then
    if [ -z "$SERVICE_URL" ]; then
        export SERVICE_URL=$SITE_BASE/seafhttp
    fi
fi

cat >> $CONF << EOFFF
# Enable cloude mode and hide \`Organization\` tab.
CLOUD_MODE = ${CLOUD_MODE:-False}

# Enable or disalbe registration on web. Default is \`False\`.
ENABLE_SIGNUP = ${ENABLE_SIGNUP:-False}

# Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = "${TIME_ZONE:-UTC}"

# Set this to seahub website's URL. This URL is contained in email notifications.
SITE_BASE = "${SITE_BASE:-http://www.example.com/}"

# Set this to your website's name. This is contained in email notifications.
SITE_NAME = "${SITE_NAME:-example.com}"

# Set seahub website's title
SITE_TITLE = "${SITE_TITLE:-Seafile}"

# If you don't want to run seahub website on your site's root path, set this option to your preferred path.
# e.g. setting it to '/seahub/' would run seahub on http://example.com/seahub/.
SITE_ROOT = "${SITE_ROOT:-/}"

FILE_SERVER_ROOT = '${SERVICE_URL:-$SITE_BASE:8082}'

# Whether to use pdf.js to view pdf files online. Default is \`True\`,  you can turn it off.
# NOTE: since version 1.4.
USE_PDFJS = True

# Activate or deactivate user when registration complete. Default is \`True\`.
# If set to \`False\`, new users need to be activated by admin in admin panel.
# NOTE: since version 1.8
ACTIVATE_AFTER_REGISTRATION = ${ACTIVATE_AFTER_REGISTRATION:-True}

# Whether to send email when a system admin adding a new member. Default is \`True\`.
# NOTE: since version 1.4.
SEND_EMAIL_ON_ADDING_SYSTEM_MEMBER = True

# Whether to send email when a system admin resetting a user's password. Default is \`True\`.
# NOTE: since version 1.4.
SEND_EMAIL_ON_RESETTING_USER_PASSWD = True

# Online preview maximum file size, defaults to 30M.
FILE_PREVIEW_MAX_SIZE = 30 * 1024 * 1024

# Age of cookie, in seconds (default: 2 weeks).
SESSION_COOKIE_AGE = 60 * 60 * 24 * 7 * 2

# Whether to save the session data on every request.
SESSION_SAVE_EVERY_REQUEST = False

# Whether a user's session cookie expires when the Web browser is closed.
SESSION_EXPIRE_AT_BROWSER_CLOSE = False

# Whether a user can make group as public. Default is False.
ENABLE_MAKE_GROUP_PUBLIC = False

# Enable or disable thumbnails
# NOTE: since version 4.0.2
ENABLE_THUMBNAIL = True

# Absolute filesystem path to the directory that will hold thumbnail files.
THUMBNAIL_ROOT = "/usr/local/seafile/seahub-data/thumbnail/thumb/"
THUMBNAIL_EXTENSION = "png"
THUMBNAIL_DEFAULT_SIZE = "24"
PREVIEW_DEFAULT_SIZE = "100"

EOFFF
