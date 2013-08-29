#!/usr/bin/env bash

# node settings
NODE_VERSION=0.10.10
NODE_SOURCE=http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz

# if node.js does not exist
if [ ! -e /opt/node/$NODE_VERSION ];
then
	echo "Provisioning Vagrant Node.js"

	# Update apt-get
	echo "Updating apt-get..."
	apt-get update

	# Install node.js
	echo "Installing Node.js $NODE_VERSION..."
	apt-get install nodejs

	# Install mongodb
	echo "Installing mongodb..."
	apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
	echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
	apt-get -y update
	apt-get -y install mongodb-10gen
	# set up the required directories and permissions
	mkdir -p /data/db
	chown mongodb /data/db

	# Clean up
	echo "Cleaning up..."
	apt-get clean

	echo "-------------------------------"
	echo "All done, now go code something"
fi