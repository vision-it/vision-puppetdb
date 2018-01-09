# Class: vision_puppetdb::explorer
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_puppetdb::explorer
#

class vision_puppetdb::explorer (

  String $explorer_image = 'puppet/puppetexplorer',
  String $explorer_version = 'latest',
  $puppetdb_servers = [ ['puppetdb.example.com', '/api'] ],
  $node_facts = [
    'operatingsystem',
    'operatingsystemrelease',
    'manufacturer',
    'productname',
    'processorcount',
    'memorytotal',
    'ipaddress',
  ],
  $unresponsive_hours = 2,
  $dashboard_panels = [
    {
    'name'  => 'Unresponsive nodes',
    'type'  => 'danger',
    'query' => '#node.report_timestamp < @"now - 2 hours"'
    },
    {
    'name'  => 'Nodes in production env',
    'type'  => 'success',
    'query' => '#node.catalog_environment = production'
    },
    {
    'name'  => 'Nodes in non-production env',
    'type'  => 'warning',
    'query' => '#node.catalog_environment != production'
    },
  ],
  ) {

  contain ::vision_docker

  file { '/etc/puppetexplorer-config.js':
    ensure  => file,
    mode    => '0644',
    content => template('vision_puppetdb/puppetexplorer-config.js.erb'),
  }

  ::docker::image { 'puppetexplorer':
    ensure    => present,
    image     => $explorer_image,
    image_tag => $explorer_version,
  }
  ->::docker::run { 'puppetexplorer':
    image            => "${explorer_image}:${explorer_version}",
    ports            => [ '8001:80' ],
    extra_parameters => [
      '--read-only=true',
    ],
    require          => File['/etc/puppetexplorer-config.js'],
  }

}
