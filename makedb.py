import os

import MySQLdb


db_host = os.environ.get(
    'DB_PORT_3306_TCP_ADDR',
    os.environ.get(
        'MYSQL_HOST',
        'db',
    ),
)
db_port = int(os.environ.get('MYSQL_PORT', '3306'))
db_user = os.environ.get(
    'DB_ENV_MYSQL_USER',
    os.environ.get(
        'MYSQL_USER',
    ),
)
db_pass = os.environ.get(
    'DB_ENV_MYSQL_PASSWORD',
    os.environ.get(
        'MYSQL_PASSWORD',
    ),
)
db_root = os.environ.get(
    'DB_ENV_MYSQL_ROOT_USER',
    os.environ.get(
        'MYSQL_ROOT',
        'root',
    ),
)
db_root_pass = os.environ.get(
    'DB_ENV_MYSQL_ROOT_PASSWORD',
    os.environ.get(
        'MYSQL_ROOT_PASSWORD',
    ),
)

if db_root_pass is None:
    print('No mysql root password provided. Not creating databases')
    exit(0)

try:
    conn = MySQLdb.connect(host=db_host,
                           port=db_port,
                           user=db_root,
                           passwd=db_root_pass)
except Exception as e:
    if isinstance(e, MySQLdb.OperationalError):
        print('Failed to connect to mysql: {}'.format(e.args[1]))
    else:
        print('Failed to connect to mysql: {}'.format(e))
    exit(1)

cursor = conn.cursor()
commands = [
    '''CREATE DATABASE IF NOT EXISTS `ccnet-db` character set = 'utf8';''',
    '''CREATE DATABASE IF NOT EXISTS `seafile-db` character set = 'utf8';''',
    '''CREATE DATABASE IF NOT EXISTS `seahub-db` character set = 'utf8';''',
    '''GRANT ALL PRIVILEGES ON `ccnet-db`.* to `{user}` identified by '{passw}';''',
    '''GRANT ALL PRIVILEGES ON `seafile-db`.* to `{user}`;''',
    '''GRANT ALL PRIVILEGES ON `seahub-db`.* to `{user}`;''',
]

for sql in commands:
    sql = sql.format(user=db_user, passw=db_pass)

    try:
        cursor.execute(sql)
    except Exception as e:
        if isinstance(e, MySQLdb.OperationalError):
            print('Failed to create database: {}'.format(e.args[1]))
        else:
            print('Failed to create database: {}'.format(e))
        exit(2)

import ssm
ssm.db_config = ssm.ExistingDBConfigurator()
ssm.db_config.mysql_host = db_host
ssm.db_config.mysql_port = db_port
ssm.db_config.seafile_mysql_user = db_user
ssm.db_config.seafile_mysql_password = db_pass

ssm.db_config.use_existing_db = True

ssm.db_config.ccnet_db_name = 'ccnet-db'
ssm.db_config.seafile_db_name = 'seafile-db'
ssm.db_config.seahub_db_name = 'seahub-db'

ssm.db_config.seahub_admin_email = os.environ.get('ADMIN_EMAIL', 'admin@example.com')
ssm.db_config.seahub_admin_password = os.environ.get('ADMIN_PASSWORD', 'youcannotguesit')

ssm.ccnet_config.ip_or_domain = '127.0.0.1'
ssm.ccnet_config.server_name = os.environ.get('SITE_NAME', 'seafile')

ssm.seahub_config.admin_email = os.environ.get('ADMIN_EMAIL', 'admin@example.com')
ssm.seahub_config.admin_email = os.environ.get('ADMIN_PASSWORD', 'youcannotguesit')

ssm.db_config.generate()
ssm.ccnet_config.generate()
ssm.seafile_config.generate()
ssm.seafdav_config.generate()
ssm.seahub_config.generate()

ssm.seahub_config.do_syncdb()
ssm.seahub_config.prepare_avatar_dir()
#ssm.db_config.create_seahub_admin()
ssm.user_manuals_handler.copy_user_manuals()
ssm.create_seafile_server_symlink()

ssm.set_file_perm()

ssm.report_success()
