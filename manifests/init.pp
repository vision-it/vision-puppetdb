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
  String $db_user            = 'puppetdb',
  Array  $environment        = [],
  String $puppetdb_version   = 'latest',
  String $postgresql_version = 'latest',
  String $ssl_key            = '/etc/puppetlabs/puppetdb/ssl/jetty_private.pem',
  String $ssl_cert           = '/etc/puppetlabs/puppetdb/ssl/jetty_public.pem'

) {

  contain ::vision_docker
  contain ::vision_puppetdb::images
  contain ::vision_puppetdb::run

  file { ['/vision/puppetdb', '/vision/puppetdb/db']:
    ensure => directory
  }

  # TODO: Certificates need to be copied
  file { '/vision/puppetdb/jetty.ini':
    ensure  => file,
    content => template('vision_puppetdb/jetty.ini.erb'),
    require => File['/vision/puppetdb']
  }

  # Order of execution
  Class['::vision_docker']
  -> Class['::vision_puppetdb::images']
  -> Class['::vision_puppetdb::run']

}
