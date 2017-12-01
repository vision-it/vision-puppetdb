require 'spec_helper_acceptance'

describe 'vision_puppetdb' do
  context 'with defaults' do
    it 'run idempotently' do
      pp = <<-FILE

        class vision_docker() {}
        class vision_puppetdb::images () {}
        class vision_puppetdb::run () {}

        file { '/vision':
          ensure => directory,
        }

        class { 'vision_puppetdb': }
      FILE

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'files provisioned' do
    describe file('/vision/puppetdb/') do
      it { is_expected.to be_directory }
    end
    describe file('/vision/puppetdb/db') do
      it { is_expected.to be_directory }
    end
    describe file('/vision/puppetdb/jetty.ini') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'jetty' }
      its(:content) { is_expected.to match 'ssl-cert' }
      its(:content) { is_expected.to match 'ssl-key' }
      its(:content) { is_expected.to match 'puppetlabs' }
    end
    describe file('/vision/puppetdb/certificate-whitelist') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'foobar' }
      its(:content) { is_expected.to match 'barfoo' }
    end
    describe file('/vision/puppetdb/config.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'certificate-whitelist' }
      its(:content) { is_expected.to match 'puppetdb' }
    end
  end
end
