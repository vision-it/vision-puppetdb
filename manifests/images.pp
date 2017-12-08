# Class: vision_gogs::images
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_gogs::images
#

class vision_puppetdb::images (

  String $puppetdb_version   = $vision_puppetdb::puppetdb_version,
  String $postgresql_version = $vision_puppetdb::postgresql_version,
  String $explorer_version   = $vision_puppetdb::explorer_version,

) {

  ::docker::image { 'postgres':
    ensure    => present,
    image     => 'puppet/puppetdb-postgres',
    image_tag => $postgresql_version,
  }

  ::docker::image { 'puppetdb':
    ensure    => present,
    image     => 'puppet/puppetdb',
    image_tag => $puppetdb_version,
  }

  if $explorer_version != undef {
    ::docker::image { 'puppetexplorer':
      ensure    => present,
      image     => 'puppet/puppetexplorer',
      image_tag => $explorer_version,
    }
  }

}
