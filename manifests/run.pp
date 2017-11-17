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

) {

  $docker_environment = concat([
  ], $environment)

  ::docker::run { 'postgres':
    image         => "postgres:${psql_version}",
    pull_on_start => true,
    env           => [
      "POSTGRES_PASSWORD=${db_password}",
    ]
  }

  ::docker::run { 'puppetdb':
    image   => "puppet/puppetdb:${puppetdb_version}",
    env     => $docker_environment,
    ports   => [ '8080:8080', '8081:8081' ],
    links   => ['postgres'],
    depends => ['postgres']
  }

}
