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
    'PUPPETDB_POSTGRES_HOSTNAME=puppetdb_postgres',
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
          '/vision/data/puppetdb/postgres-extensions.sql:/docker-entrypoint-initdb.d/extensions.sql:ro',
          {
            'type'   => 'tmpfs',
            'target' => '/tmp',
            'tmpfs'  => {
              'size' => 1000000000 # 1GB
            },
          },
          {
            'type'   => 'tmpfs',
            'target' => '/run/postgresql',
            'tmpfs'  => {
              'size' => 10000000 # 10MB
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
          '/vision/data/puppetdb/ssl:/etc/puppetlabs/puppetdb/ssl:ro',
          '/usr/local/share/ca-certificates/VisionCA.crt:/etc/puppetlabs/puppetdb/ssl/ca.pem:ro',
          '/vision/data/puppetdb/jetty.ini:/etc/puppetlabs/puppetdb/conf.d/jetty.ini:ro',
          '/vision/data/puppetdb/config.conf:/etc/puppetlabs/puppetdb/conf.d/config.conf:ro',
          '/vision/data/puppetdb/certificate-whitelist:/etc/puppetlabs/puppetdb/conf.d/certificate-whitelist:ro',
        ],
        'environment' => $docker_environment,
        'deploy' => {
          labels => [
            'traefik.port=8080',
            'traefik.frontend.rule=PathPrefix:/pdb',
            'traefik.enable=true',
            'traefik.frontend.whiteList.sourceRange=10.55.63.0/24',
            'traefik.docker.network=vision_default',
          ],
        },
        'ports'  => [
          '8081:8081',
        ],
        # TODO: check if puppetdb container can be run read-only
      }
    }
  }

  vision_docker::to_compose { 'puppetdb':
    compose => $compose,
  }

}
