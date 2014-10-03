#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 7.x
# It has been tested on CentOS 7.0 64bit

set -e

if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if which puppet > /dev/null 2>&1; then
  echo "Puppet is already installed."
  exit 0
fi

# Install puppet labs repo
echo "Configuring PuppetLabs repo..."
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

# Install Puppet...
echo "Installing puppet"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo http://mirror.centos.org/centos/7/os/x86_64/
sudo yum install --nogpgcheck -y puppet > /dev/null

echo "Puppet installed!"
