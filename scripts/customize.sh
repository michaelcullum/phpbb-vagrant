#!/bin/sh

# Permissions for virtual host
cd /var/www/
sudo chown -R www-data phpbb

# Ensure composer deps are installed
cd phpbb/phpBB
php ../composer.phar install

# Delete the db and make a new one
rm -rf /tmp/phpbb.sqlite3
rm -rf /var/www/phpbb/phpBB/config.php
cd /vagrant
php /var/www/phpbb/phpBB/install/phpbbcli.php install ./phpbb-install-config.yml

# Uncomment this to recompile php7 on provisioning (NOTE: Slow). You can also change it
# to compile other versions of php if you wish (e.g 5.6)
/vagrant/makephp 7

# Set the virtual host up
sudo rm -rf /etc/nginx/conf.d/default.conf
sudo cp /vagrant/default.conf /etc/nginx/conf.d/default.conf

sudo rm -rf /var/www/default/
sudo ln -sf /var/www/phpbb/phpBB /var/www/default

# Set to PHP 7 debug mode and restart php-fpm.
# Adapt this line if you want to set a different deafult php version
/vagrant/newphp 7 debug
