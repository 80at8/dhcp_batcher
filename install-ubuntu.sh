#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo apt-get -y install php7.0 php7.0-common php7.0-mbstring php7.0-xml php7.0-fpm php7.0-pgsql
sudo apt-get -y install nginx
sudo apt-get -y install redis-server
sudo apt-get -y install postgresql

/usr/bin/sudo -u postgres psql -c "CREATE USER dhcp_batcher WITH PASSWORD 'dhcp_batcher';"
/usr/bin/sudo -u postgres psql -c "DROP DATABASE IF EXISTS dhcp_batcher;"
/usr/bin/sudo -u postgres psql -c "CREATE DATABASE dhcp_batcher OWNER dhcp_batcher ENCODING 'utf8';"
/usr/bin/sudo -u postgres psql dhcp_batcher -c "CREATE EXTENSION citext;"

/bin/cp -r $DIR/dhcp_batcher /usr/share/dhcp_batcher
/bin/cp -r /usr/share/dhcp_batcher/.env.example /usr/share/dhcp_batcher/.env
/usr/bin/php /usr/share/dhcp_batcher/artisan key:generate

sudo apt-get -y install composer
(cd /usr/share/dhcp_batcher; composer install)

sudo /bin/chown -R www-data:www-data /usr/share/dhcp_batcher

sudo /bin/cp -rf $DIR/conf/php.ini /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm
sudo /bin/cp -rf $DIR/conf/default /etc/nginx/sites-available/default
sudo systemctl reload nginx