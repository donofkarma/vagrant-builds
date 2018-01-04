#!/usr/bin/env bash

# If apache2 does not exist
echo "INFO: Provisioning Vagrant LAMP"

# Update apt-get
echo "INFO: Updating apt-get..."
add-apt-repository ppa:ondrej/php
add-apt-repository ppa:nijel/phpmyadmin
apt-get update
echo "INFO: Updating apt-get... Done."

# Install Apache
echo "INFO: Installing apache2..."
apt-get install -y apache2
echo "INFO: Installing apache2... Done."

# Enable mod_rewrite
echo "INFO: Enabling additional Apache modules..."
a2enmod rewrite
a2enmod deflate
echo "INFO: Enabling additional Apache modules... Done."

# Update vhosts file
echo "INFO: Updating vhosts..."
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.old
cp /vagrant/provision/config/server/000-default.conf /etc/apache2/sites-available/000-default.conf
echo "INFO: Updating vhosts... Done."

# Install PHP7
echo "INFO: Installing php7.1..."
apt-get install -y php7.1 php7.1-common php7.1-json php7.1-opcache php7.1-cli php7.1-mysql php7.1-fpm php7.1-curl php7.1-gd libapache2-mod-php7.1 php7.1-zip
echo "INFO: Installing php7.1... Done."

# Install extras
echo "INFO: Installing git postfix zip unzip..."
apt-get install -y git postfix zip unzip
echo "INFO: Installing git postfix zip unzip... Done"

# Install MySQL
echo "INFO: Installing mysql..."
echo "mysql-server-5.6 mysql-server/root_password password vagrant" | debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password vagrant" | debconf-set-selections
apt-get install -y mysql-server-5.6
echo "INFO: Installing mysql... Done."

# If phpmyadmin does not exist
if [ ! -f /usr/share/phpmyadmin/config.inc.php ]; then
    # Used debconf-get-selections to find out what questions will be asked
    # This command needs debconf-utils

    # Handy for debugging. clear answers phpmyadmin:
    # echo PURGE | debconf-communicate phpmyadmin

    echo "INFO: Installing phpmyadmin..."

    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

    echo 'phpmyadmin phpmyadmin/app-password-confirm password vagrant' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password vagrant' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/password-confirm password vagrant' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/setup-password password vagrant' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/database-type select mysql' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password vagrant' | debconf-set-selections

    echo 'dbconfig-common dbconfig-common/mysql/app-pass password vagrant' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/mysql/app-pass password' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password vagrant' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password vagrant' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password vagrant' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password vagrant' | debconf-set-selections

    apt-get install -y phpmyadmin

    echo "INFO: Installing phpmyadmin... Done."
fi

# Create temp tools directory
mkdir /vagrant/tools

# Install Composer
if [[ ! -d "/usr/local/bin/composer/composer.phar" ]]; then
    cd /vagrant/tools

    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
        >&2 echo 'ERROR: Invalid installer signature'
        rm composer-setup.php
    fi

    php composer-setup.php --quiet
    rm composer-setup.php

    mv composer.phar /usr/local/bin/composer
fi

if [[ ! -d "/vagrant/public_html" ]]; then
    echo "INFO: Installing Composer dependencies..."

    cd /vagrant
    composer install --prefer-dist
fi

# Symlinking public_html
echo "INFO: Symlinking public_html to /var/www/html..."
rm -rf /var/www/html
ln -fs /vagrant/public_html/ /var/www/html
echo "INFO: Symlinking public_html to /var/www/html... Done"

# Restart services
echo "INFO: Restarting Apache..."
/etc/init.d/apache2 restart
echo "INFO: Restarting Apache... Done."

# Clean up
echo "INFO: Cleaning up..."
rm -rf /vagrant/tools
apt-get clean
echo "INFO: Cleaning up... Done."

echo "INFO: Provisioning Vagrant LAMP complete!"
