require 'spec_helper'
require 'hiera'

describe 'vision_puppetdb' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:pre_condition) { 'include vision_docker' }

      # Default check to see if manifest compiles
      context 'compile' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
