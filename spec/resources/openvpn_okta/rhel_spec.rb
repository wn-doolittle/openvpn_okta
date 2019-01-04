# frozen_string_literal: true

require_relative '../openvpn_okta'

describe 'openvpn_okta::rhel' do
  include_context 'openvpn_okta'

  platform 'centos'

  it_behaves_like 'any platform'

  context 'the :install action' do
    default_attributes['test']['action'] = :install

    it { is_expected.to install_package('gnupg') }
    it { is_expected.to install_package('ca-certificates') }

    it do
      is_expected.to create_packagecloud_repo('socrata-platform/okta-openvpn')
        .with(type: 'rpm')
    end
  end

  context 'the :remove action' do
    default_attributes['test']['action'] = :remove

    it { is_expected.to remove_package('okta-openvpn') }
    it { is_expected.to remove_yum_repository('socrata-platform_okta-openvpn') }
  end
end
