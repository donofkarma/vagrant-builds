#!/usr/bin/env bash

# node settings
NODE_VERSION=0.10.
NODE_SOURCE=http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz

# if node.js does not exist
if [ ! -e /opt/node/$NODE_VERSION ];
then
    echo "INFO: Provisioning Vagrant node.js"

    # Update apt-get
    echo "INFO: Updating apt-get..."
    apt-get update

    # Install git
    echo "INFO: Installing git..."
    apt-get install -y git-core

    # Install node.js
    # Install node.js
    echo "INFO: Installing node.js $NODE_VERSION..."
    apt-get update
    apt-get install -y python-software-properties python g++ make
    add-apt-repository -y ppa:chris-lea/node.js
    apt-get update
    apt-get install -y nodejs

    # Install mongodb
    echo "INFO: Installing mongodb..."
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
    apt-get -y update
    apt-get -y install mongodb-10gen
    # Set up the required directories and permissions
    mkdir -p /data/db
    chown mongodb /data/db

    # Clean up
    echo "INFO: Cleaning up..."
    apt-get clean

    echo "INFO: Provisioning Vagrant node.js complete!"
fi
