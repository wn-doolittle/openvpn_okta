# frozen_string_literal: true

require_relative '../openvpn_okta'

describe 'openvpn_okta::debian' do
  include_context 'openvpn_okta'

  platform 'ubuntu'

  it_behaves_like 'any platform'

  context 'the :install action' do
    default_attributes['test']['action'] = :install

    it { is_expected.to install_package('gnupg') }

    it do
      is_expected.to create_packagecloud_repo('socrata-platform/okta-openvpn')
        .with(type: 'deb')
    end
  end

  context 'the :remove action' do
    default_attributes['test']['action'] = :remove

    it { is_expected.to purge_package('okta-openvpn') }
    it { is_expected.to remove_apt_repository('socrata-platform_okta-openvpn') }
  end
end
