#
# This file is used to test the Puppet module locally using Puppet apply.
# See `examples/puppet_apply.sh` for the script that runs this file.
#
$image_name='ceos'
$image_tag='4.34.2F'
$image_filename='cEOS64-lab-4.34.2F.tar.xz'

# NOTE The source URLs listed here will not work due to login requirements with Arista.
# You will need to download the image file and checksum manually and place it in an accessible location.
$image_source='https://downloads.arista.com/cEOS-lab/4.34/EOS-4.34.2F/cEOS64-lab-4.34.2F.tar.xz'
$image_checksum_url='https://downloads.arista.com/cEOS-lab/4.34/EOS-4.34.2F/cEOS64-lab-4.34.2F.tar.xz.sha512sum'

# Download the container image file
archive { "/tmp/${image_filename}":
  ensure      => present,
  source      => $image_source,
  digest_type => 'sha512',
  digest_url  => $image_checksum_url,
}

# Apply the containerlab class with specific parameters
class { 'containerlab':
  manage_install       => true,
  manage_image_imports => true,
  manage_topologies    => true,
  image_imports        => {
    'arista_ceos' => {
      'image_file' => "/tmp/${image_filename}",
      'image_name' => $image_name,
      'image_tag'  => $image_tag,
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
