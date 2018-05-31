require 'spec_helper'
require 'puppetlabs_spec_helper/module_spec_helper'

describe 'domain_membership' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) do
        {
          domain: 'test.domain',
          username: 'testuser',
          password: 'password1',
        }
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
