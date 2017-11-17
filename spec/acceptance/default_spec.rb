require 'spec_helper_acceptance'

describe 'vision_puppetdb' do
  context 'with defaults' do
    it 'run idempotently' do
      pp = <<-EOS

        class vision_docker() {}
        class vision_puppetdb::images () {}
        class vision_puppetdb::run () {}

        file { '/vision':
          ensure => directory,
        }

        class { 'vision_puppetdb': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'files provisioned' do
    describe file('/vision/puppetdb/') do
      it { is_expected.to be_directory }
    end
  end
end
