#!/usr/bin/env bash

mkdir -p /etc/puppet/modules
(puppet module list | grep puppetlabs-vcsrepo) || puppet module install puppetlabs/vcsrepo
