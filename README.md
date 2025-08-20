# containerlab

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage](#usage)

## Description

This module will install and manage ContainerLab services. ContainerLab will install
docker-ce as part of the installation process.
It will also remove any existing podman service/packages (if previously installed), 
so apply with caution!

## Setup

Install the module as you would with any other Puppet module for use with Puppet Core or
Puppet Enteprise. 

## Usage

Classify the module on any node that you want ContainerLab services to be avaialble.
See the puppet_apply.pp file in the examples folder for local usage pattern.

```
#
# Apply the containerlab class with specific parameters
#
class { 'containerlab':
  manage_install       => true,
  manage_image_imports => true,
  manage_topologies    => true,
  image_imports        => {
    'arista_ceos' => {
      'image_file' => '/tmp/cEOS64-lab-4.34.2F.tar.xz',
      'image_name' => 'ceos',
      'image_tag'  => '4.34.2F',
    },
  },
  topologies           => {
    'arista_ceos' => {
      'topology_file' => '/etc/containerlab/arista_ceos-topology.yml',
      'topology'      => {
        'name'      => 'arista',
        'kinds'     => {
          'ceos' => {
            'image' => 'ceos',
            'tag'   => '4.34.2F',
          },
        },
        'nodes'     => {
          'ceos1' => { 'kind' => 'ceos' },
          'ceos2' => { 'kind' => 'ceos' },
        },
        'endpoints' => ['ceos1:eth1', 'ceos2:eth1'],
      },
    },
  },
}
```
Note: You will need to make the image files available locally before the containerlab resource can import them
The archive resource/module can be used for this purpose, for example: 

```
#
# Download the container image file for local use
#
archive { "/tmp/cEOS64-lab-4.34.2F.tar.xz":
  ensure      => present,
  source      => 'https://downloads.arista.com/cEOS-lab/4.34/EOS-4.34.2F/cEOS64-lab-4.34.2F.tar.xz',
  digest_type => 'sha512',
  digest_url  => 'https://downloads.arista.com/cEOS-lab/4.34/EOS-4.34.2F/cEOS64-lab-4.34.2F.tar.xz.sha512sum',
  before      => Class['containerlab'],
}
``` 