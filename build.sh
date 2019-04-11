#!/bin/bash
# Packer build script

set -e

# Update system packages
sudo yum update -y
sudo yum -y install git

# Add repos required for PHP 7.2
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum update -y

# Install required packages
# NOTE: ruby required for CodeDeploy agent
sudo yum -y install \
    ruby \
    php72u \
    php72u-mysqlnd.x86_64 \
    php72u-opcache \
    php72u-xml \
    php72u-gd \
    php72u-devel \
    php72u-intl \
    php72u-mbstring \
    php72u-bcmath \
    php72u-soap \
    php72u-json

# Install WP CLI
sudo curl -s -o wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp
sudo mv -f wp /usr/local/bin/

# Additional logrotate config
sudo chown root:root ~ec2-user/applogs
sudo chmod 644 ~ec2-user/applogs
sudo mv -f ~ec2-user/applogs /etc/logrotate.d/

# Setup wp_import
sudo chown ec2-user:ec2-user ~ec2-user/wp_import.sh
sudo chmod 700 ~ec2-user/wp_import.sh

sudo chown root:root ~ec2-user/wp_import
sudo chmod 644 ~ec2-user/wp_import
sudo mv -f ~ec2-user/wp_import /etc/cron.d/

# Setup AWS CW logging
sudo yum install -y awslogs

sudo chown root:root \
    ~ec2-user/awscli.conf \
    ~ec2-user/awslogs.conf

sudo chmod 640 \
    ~ec2-user/awscli.conf \
    ~ec2-user/awslogs.conf

sudo mv -f \
    ~ec2-user/awscli.conf \
    ~ec2-user/awslogs.conf \
    /etc/awslogs/

sudo systemctl enable awslogsd

# Install CodeDeploy agent
sudo curl -s -o install https://aws-codedeploy-eu-west-1.s3.amazonaws.com/latest/install
sudo chmod +x install
sudo ./install auto
sudo rm -f install
