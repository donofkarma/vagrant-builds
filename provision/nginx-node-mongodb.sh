#!/usr/bin/env bash

# node settings
NODE_VERSION=4.2.3
NODE_SOURCE=http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz

echo "INFO: Provisioning Vagrant node.js"

# Update apt-get
echo "INFO: Updating apt-get..."
apt-get update
echo "INFO: Updating apt-get... Done."

# Install git
echo "INFO: Installing git..."
apt-get install -y git-core
echo "INFO: Installing git... Done."

# Install nginx
echo "Info: Installing nginx..."
apt-get install -y nginx
echo "Info: Installing nginx... Done."

# Update config/hosts file
echo "INFO: Updating config/hosts..."

VHOST=$(cat <<EOF
server {
    listen 3000;
    listen 443 ssl;
    server_name localhost;

    root /vagrant/site/;
    index index.html;

    # Important for VirtualBox
    sendfile off;

    location /assets/ {
       try_files $uri $uri/ =404;
    }

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
)

echo "${VHOST}" > /etc/nginx/sites-available/default

echo "INFO: Updating config/hosts... Done."

# Install node.js
echo "INFO: Installing node.js $NODE_VERSION..."
apt-get update
apt-get install -y python-software-properties python g++ make
add-apt-repository -y ppa:chris-lea/node.js
apt-get update
apt-get install -y nodejs
echo "INFO: Installing node.js $NODE_VERSION... Done."

# Install mongodb
echo "INFO: Installing mongodb..."
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
apt-get -y update
apt-get -y install mongodb-10gen
# Set up the required directories and permissions
mkdir -p /data/db
chown mongodb /data/db
echo "INFO: Installing mongodb... Done."

# Clean up
echo "INFO: Cleaning up apt-get..."
apt-get clean
echo "INFO: Cleaning up apt-get... Done."

echo "INFO: Provisioning Vagrant node.js complete!"
