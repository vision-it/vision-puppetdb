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
  Array  $cert_whitelist     = [],
  String $puppetdb_version   = 'latest',
  String $postgresql_version = 'latest',
  String $ssl_key            = '/etc/puppetlabs/puppetdb/ssl/jetty_private.pem',
  String $ssl_cert           = '/etc/puppetlabs/puppetdb/ssl/jetty_public.pem',
  String $private_target     = '/etc/puppetlabs/puppet/ssl/jetty_private.pem',
  String $public_target      = '/etc/puppetlabs/puppet/ssl/jetty_public.pem',
  String $private_source     = "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
  String $public_source      = "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
) {

  contain ::vision_docker
  contain ::vision_puppetdb::images
  contain ::vision_puppetdb::run

  file { ['/vision/puppetdb', '/vision/puppetdb/db']:
    ensure => directory
  }

  file { '/vision/puppetdb/jetty.ini':
    ensure  => file,
    content => template('vision_puppetdb/jetty.ini.erb'),
    require => File['/vision/puppetdb']
  }

  file { '/vision/puppetdb/config.conf':
    ensure  => file,
    content => file('vision_puppetdb/config.conf'),
    require => File['/vision/puppetdb']
  }

  file { '/vision/puppetdb/certificate-whitelist':
    ensure  => file,
    content => $cert_whitelist.join("\n"),
    require => File['/vision/puppetdb']
  }

  exec {'jetty_private.pem':
    command => "cp ${private_source} ${private_target} && chmod 444 ${private_target}",
    path    => '/bin:/usr/bin',
    unless  => "test -f ${private_target}"
  }

  exec {'jetty_public.pem':
    command => "cp ${public_source} ${public_target} && chmod 444 ${public_target}",
    path    => '/bin:/usr/bin',
    unless  => "test -f ${public_target}"
  }

  # Order of execution
  Class['::vision_docker']
  -> Class['::vision_puppetdb::images']
  -> Class['::vision_puppetdb::run']

}
