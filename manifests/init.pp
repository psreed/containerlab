# @summary Installs and manages Containerlab
#
# @example
#   include containerlab
#
#
# @param manage_install
#   Whether to manage the installation of Containerlab. Defaults to true.
# @param manage_image_imports
#   Whether to manage the import of container images. Defaults to true.
# @param manage_topologies
#   Whether to manage the topologies defined in the `topologies` parameter. Defaults to true.
# @param install_string
#   The command to install Containerlab. Defaults to the official installation script.
# @param image_imports
#   A hash of container imports to be used with Containerlab.
#   Example:
#    image_imports        => {
#      'arista_ceos' => {
#        'image_file' => "/tmp/cEOS64-lab-4.34.2F.tar.xz",
#        'image_name' => ceos,
#        'image_tag'  => 4.34.2F,
#      },
#
#   Note: The `image_file` must be a local file, use the archive resource/module to download it first if needed.
#
# @param topologies
#   A hash of topologies to be managed by ContainerLab.
#   Example:
#      topologies           => {
#          'arista_ceos' => {
#            'topology_file' => '/etc/containerlab/arista_ceos-topology.yml',
#            'topology'      => {
#              'name'      => 'arista',
#              'kinds'     => {
#                'ceos' => {
#                  'image' => 'ceos',
#                  'tag'   => '4.34.2F',
#                },
#              },
#              'nodes'     => {
#                'ceos1' => { 'kind' => 'ceos' },
#                'ceos2' => { 'kind' => 'ceos' },
#              },
#              'endpoints' => ['ceos1:eth1', 'ceos2:eth1'],
#            },
#          },
#        },
#
class containerlab (
  Boolean $manage_install = true,
  Boolean $manage_image_imports = true,
  Boolean $manage_topologies = true,
  String[1] $install_string = 'curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"',
  Hash $image_imports = {},
  Hash $topologies = {},
) {
  if $manage_install {
    exec { 'install_containerlab':
      command => $install_string,
      path    => '/usr/local/bin:/usr/bin:/bin',
      creates => '/usr/bin/containerlab',
    }
  }
  # Import defined container images
  if $manage_image_imports {
    $image_imports.each |$name, $params| {
      $image_file = $params['image_file']
      $image_name = $params['image_name']
      $image_tag  = $params['image_tag']

      exec { "import_containerlab_image_${name}":
        command => "docker import ${image_file} ${image_name}:${image_tag}",
        path    => '/usr/local/bin:/usr/bin:/bin',
        unless  => "docker image list | grep -q '^${image_name}\\s\\+${image_tag}\\s'",
        require => Exec['install_containerlab'],
      }
    }
  }

  # Apply the defined topologies
  if $manage_topologies {
    $topologies.each |$name, $params| {
      $topology_file = $params['topology_file']
      $topology = $params['topology']

      file { $topology_file:
        ensure  => file,
        content => epp('containerlab/topology.yaml.epp', { 'topology' => $topology }),
        require => Exec['install_containerlab'],
      }

      exec { "apply_containerlab_topology_${name}":
        command => "containerlab deploy -t ${topology_file}",
        path    => '/usr/local/bin:/usr/bin:/bin',
        require => File[$topology_file],
      }
    }
  }
}
