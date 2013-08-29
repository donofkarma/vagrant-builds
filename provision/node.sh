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

	# install node.js
	echo "Installing Node.js $NODE_VERSION..."
	cd /usr/src
	wget --quiet $NODE_SOURCE
	tar xf node-v$NODE_VERSION.tar.gz
	cd node-v$NODE_VERSION

	# configure
	./configure --prefix=/opt/node/$NODE_VERSION

	# make and install
	make
	make install

	# Clean up
	apt-get clean

	echo "All done, now go code something"
fi