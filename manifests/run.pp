# Class: vision_gogs::run
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_gogs::run
#

class vision_puppetdb::run (

  Array $environment       = $::vision_puppetdb::environment,
  String $puppetdb_version = $::vision_puppetdb::puppetdb_version,
  String $psql_version     = $::vision_puppetdb::postgresql_version,
  String $db_password      = $::vision_puppetdb::db_password,
  String $db_user          = $::vision_puppetdb::db_user,

) {

  $docker_environment = concat([
    "PUPPETDB_PASSWORD=${db_password}",
    "PUPPETDB_USER=${db_user}",
    'PUPPETDB_DATABASE_CONNECTION=//postgres:5432/puppetdb',
  ], $environment)

  ::docker::run { 'postgres':
    image            => "puppet/puppetdb-postgres:${psql_version}",
    expose           => ['5432'],
    volumes          => [
      '/vision/puppetdb/db:/var/lib/postgresql/data'
    ],
    env              => [
      "POSTGRES_PASSWORD=${db_password}",
      "POSTGRES_USER=${db_user}"
    ],
    extra_parameters => [
      '--read-only=true',
      '--tmpfs=/tmp',
      '--tmpfs=/run/postgresql',
    ]
  }

  ::docker::run { 'puppetdb':
    image     => "puppet/puppetdb:${puppetdb_version}",
    env       => $docker_environment,
    ports     => [ '8080:8080', '8081:8081' ],
    links     => ['postgres'],
    volumes   => [
      '/etc/puppetlabs/puppet/ssl/:/etc/puppetlabs/puppetdb/ssl:ro',
      '/vision/pki/VisionCA.crt:/etc/puppetlabs/puppetdb/ssl/certs/ca.pem:ro',
      '/vision/puppetdb/jetty.ini:/etc/puppetlabs/puppetdb/conf.d/jetty.ini:ro',
      '/vision/puppetdb/config.conf:/etc/puppetlabs/puppetdb/conf.d/config.conf:ro',
      '/vision/puppetdb/certificate-whitelist:/etc/puppetlabs/puppetdb/conf.d/certificate-whitelist:ro'
    ],
    depends   => ['postgres'],
    subscribe => [
      File['/vision/puppetdb/jetty.ini'],
      File['/vision/puppetdb/config.conf'],
      File['/vision/puppetdb/certificate-whitelist'],
    ]
    # TODO: check if puppetdb container can be run read-only
  }

}
