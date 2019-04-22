# Class: vision_puppetdb::docker
# ===========================

class vision_puppetdb::docker (

  Array $environment       = $::vision_puppetdb::environment,
  String $puppetdb_version = $::vision_puppetdb::puppetdb_version,
  String $psql_version     = $::vision_puppetdb::postgresql_version,
  String $db_password      = $::vision_puppetdb::db_password,
  String $db_user          = $::vision_puppetdb::db_user,

  ) {

  $docker_environment = concat([
    "PUPPETDB_PASSWORD=${db_password}",
    "PUPPETDB_USER=${db_user}",
    'PUPPETDB_DATABASE_CONNECTION=//puppetdb_postgres:5432/puppetdb',
    'USE_PUPPETSERVER=false'
  ], $environment)

  $compose = {
    'version' => '3.7',
    'services' => {
      # note: postgresql runs on port 5432
      'puppetdb_postgres' => {
        'image'       => "postgres:${psql_version}",
        'volumes'     => [
          '/vision/data/puppetdb/postgresql_data:/var/lib/postgresql/data',
          '/vision/data/puppetdb/extensions.sql:/docker-entrypoint-initdb.d/extensions.sql:ro',
          {
            'type'   => 'tmpfs',
            'target' => '/tmp',
            'tmpfs'  => {
              'size' => '1000000000' # 1GB
            },
          },
          {
            'type'   => 'tmpfs',
            'target' => '/run/postgresql',
            'tmpfs'  => {
              'size' => '10000000' # 10MB
            },
          },
        ],
        'environment' => [
          "POSTGRES_PASSWORD=${db_password}",
          "POSTGRES_USER=${db_user}",
        ],
        'read_only'   => true,
      },
      'puppetdb' => {
        # note: puppetdb runs on port 8080 / 8081
        'image'       => "puppet/puppetdb:${puppetdb_version}",
        'volumes'     => [
          '/etc/puppetlabs/puppet/ssl/:/etc/puppetlabs/puppetdb/ssl:ro',
          '/vision/data/pki/VisionCA.crt:/etc/puppetlabs/puppetdb/ssl/certs/ca.pem:ro',
          '/vision/data/puppetdb/jetty.ini:/etc/puppetlabs/puppetdb/conf.d/jetty.ini:ro',
          '/vision/data/puppetdb/config.conf:/etc/puppetlabs/puppetdb/conf.d/config.conf:ro',
          '/vision/data/puppetdb/certificate-whitelist:/etc/puppetlabs/puppetdb/conf.d/certificate-whitelist:ro',
        ],
        'environment' => $docker_environment,
        # TODO: check if puppetdb container can be run read-only
      }
    }
  }
  # note: application runs on port 80

  # TODO: maybe make this a defined type / resource?
  file{ '/vision/data/swarm/puppetdb.yaml':
    ensure  => present,
    content => inline_template("# This file is managed by Puppet\n<%= @compose.to_yaml %>")
  }

}
