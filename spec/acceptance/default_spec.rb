require 'spec_helper_acceptance'

describe 'vision_puppetdb' do
  context 'with defaults' do
    it 'run idempotently' do
      pp = <<-FILE

        # mock classes
        class vision_gluster::node() {}

        file { ['/vision', '/vision/data', '/vision/data/swarm']:
          ensure => directory,
        }
        file { '/root/private.pem':
          ensure  => file,
          content => 'private',
        }
        file { '/root/public.pem':
          ensure  => file,
          content => 'public',
        }

        class { 'vision_puppetdb': }
      FILE

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'files provisioned' do
    describe file('/vision/data/puppetdb/') do
      it { is_expected.to be_directory }
    end
    describe file('/vision/data/puppetdb/postgresql_data') do
      it { is_expected.to be_directory }
    end
    describe file('/vision/data/puppetdb/jetty.ini') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'jetty' }
      its(:content) { is_expected.to match 'ssl-cert' }
      its(:content) { is_expected.to match 'ssl-key' }
      its(:content) { is_expected.to match 'puppetlabs' }
    end
    describe file('/etc/puppetlabs/puppet/ssl/jetty_private.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode '444' }
      its(:content) { is_expected.to match 'private' }
    end
    describe file('/etc/puppetlabs/puppet/ssl/jetty_public.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode '444' }
      its(:content) { is_expected.to match 'public' }
    end
    describe file('/vision/data/puppetdb/certificate-whitelist') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'foobar' }
      its(:content) { is_expected.to match 'barfoo' }
    end
    describe file('/vision/data/puppetdb/config.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'certificate-whitelist' }
      its(:content) { is_expected.to match 'puppetdb' }
    end
    describe file('/vision/data/swarm/puppetdb.yaml') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'managed by Puppet' }
      it { is_expected.to contain 'puppetdb_postgres' }
      it { is_expected.to contain 'image: postgres:latest' }
      it { is_expected.to contain '/var/lib/postgresql/data' }
      it { is_expected.to contain '/docker-entrypoint-initdb.d/extensions.sql:ro' }
      it { is_expected.to contain 'tmpfs' }
      it { is_expected.to contain 'POSTGRES_PASSWORD=foobar' }
      it { is_expected.to contain 'POSTGRES_USER=puppetdb' }
      it { is_expected.to contain 'image: puppet/puppetdb:latest' }
      it { is_expected.to contain '/etc/puppetlabs/puppetdb/conf.d/jetty.ini:ro' }
      it { is_expected.to contain 'certificate-whitelist:ro' }
      it { is_expected.to contain 'PUPPETDB_PASSWORD=foobar' }
      it { is_expected.to contain 'PUPPETDB_USER=puppetdb' }
      it { is_expected.to contain 'PUPPETDB_DATABASE_CONNECTION=//puppetdb_postgres:5432/puppetdb' }
      it { is_expected.to contain 'EXTERNAL_ENV_VAR=ok' }
    end
  end
end
