#!/usr/bin/env bash

# if apache2 does no exist
if [ ! -f /etc/apache2/apache2.conf ];
then
	echo "Provisioning Vagrant LAMP"

	# Update apt-get
	echo "Updating apt-get..."
	apt-get update

	# Install MySQL
	echo "Installing mysql..."
	echo "mysql-server-5.5 mysql-server/root_password password vagrant" | debconf-set-selections
	echo "mysql-server-5.5 mysql-server/root_password_again password vagrant" | debconf-set-selections
	apt-get install -y mysql-server

	# Install apache2
	echo "Installing apache2..."
	apt-get install -y apache2
	rm -rf /var/www
	ln -fs /vagrant/src /var/www
	echo "/var/www === /vagrant/src"

	# Install PHP5 support
	echo "Installing php5..."
	apt-get install -y php5 libapache2-mod-php5 php-apc php5-mysql php5-dev

	# Install OpenSSL
	echo "Installing OpenSSL..."
	apt-get install -y openssl

	# If phpmyadmin does not exist
	if [ ! -f /etc/phpmyadmin/config.inc.php ];
	then

		# Used debconf-get-selections to find out what questions will be asked
		# This command needs debconf-utils

		# Handy for debugging. clear answers phpmyadmin: echo PURGE | debconf-communicate phpmyadmin

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
	fi

	# Enable mod_rewrite
	echo "Enabling mod_rewrite"
	a2enmod rewrite

	# Enable SSL
	echo "Enabling SSL"
	a2enmod ssl

	# Restart services
	/etc/init.d/apache2 restart

	# Clean up
	apt-get clean

	echo "All done, now go code something"
fi