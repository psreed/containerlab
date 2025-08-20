#!/bin/bash -x
MODULEPATH="/etc/puppetlabs/code/environments/testing/modules"
MODULENAME="containerlab"
clear
sudo mkdir -p $MODULEPATH
sudo puppet module --modulepath $MODULEPATH install puppet-archive puppetlabs-stdlib
sudo ln -s $(pwd) "${MODULEPATH}/${MODULENAME}"
sudo puppet apply -t --modulepath $MODULEPATH examples/puppet_apply.pp