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

  String $x509_key,
  String $x509_cert,
  String $db_password,
  String $db_user            = 'puppetdb',
  Array  $environment        = [],
  Array  $cert_whitelist     = [],
  String $puppetdb_version   = 'latest',
  String $postgresql_version = 'latest',
) {

  contain ::vision_gluster::node

  file { ['/vision/data/puppetdb', '/vision/data/puppetdb/ssl', '/vision/data/puppetdb/postgresql_data']:
    ensure => directory
  }

  file { '/vision/data/puppetdb/postgres-extensions.sql':
    ensure  => file,
    content => file('vision_puppetdb/extensions.sql'),
    require => File['/vision/data/puppetdb']
  }

  file { '/vision/data/puppetdb/jetty.ini':
    ensure  => file,
    content => template('vision_puppetdb/jetty.ini.erb'),
    require => File['/vision/data/puppetdb']
  }

  file { '/vision/data/puppetdb/config.conf':
    ensure  => file,
    content => file('vision_puppetdb/config.conf'),
    require => File['/vision/data/puppetdb']
  }

  file { '/vision/data/puppetdb/certificate-whitelist':
    ensure  => file,
    content => $cert_whitelist.join("\n"),
    require => File['/vision/data/puppetdb']
  }

  file { '/vision/data/puppetdb/ssl/jetty_private.pem':
    ensure  => file,
    mode    => '0444',
    content => $x509_key,
    require => File['/vision/data/puppetdb/ssl'],
  }

  file { '/vision/data/puppetdb/ssl/jetty_public.pem':
    ensure  => file,
    mode    => '0444',
    content => $x509_cert,
    require => File['/vision/data/puppetdb/ssl'],
  }

  contain ::vision_puppetdb::docker

}
