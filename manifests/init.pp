# Class: vision_puppetdb
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_puppetdb
#

class vision_puppetdb (

  String $db_password,
  Array  $environment        = [],
  String $puppetdb_version   = 'latest',
  String $postgresql_version = 'latest'

) {

  contain ::vision_docker
  contain ::vision_puppetdb::images
  contain ::vision_puppetdb::run

  file { '/vision/puppetdb':
    ensure => directory
  }

  # Order of execution
  Class['::vision_docker']
  -> Class['::vision_puppetdb::images']
  -> Class['::vision_puppetdb::run']

}
